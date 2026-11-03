# frozen_string_literal: true

require_relative "test_helper"

class StepsTest < Minitest::Test
  def plan(roles:, skip: [])
    Bootstrap::Steps.plan(Bootstrap::Options.new(roles:, skip:)).map(&:name)
  end

  def test_a_base_mac_runs_the_shared_steps_in_order
    assert_equal %w[roles dotfiles zlocal ssh forgejo brew defaults apps deriva], plan(roles: %w[base])
  end

  def test_roles_add_their_steps_and_the_mudge_roles_share_one
    assert_includes plan(roles: %w[base dev]), "skills"
    refute_includes plan(roles: %w[base dev]), "mudge"
    assert_equal 1, plan(roles: %w[base ci-runner backup]).count("mudge")
    assert_includes plan(roles: %w[base archivist]), "archivist"
  end

  class RecordingShell
    attr_reader :commands, :envs

    def initialize(secret: nil)
      @commands = []
      @envs = []
      @secret = secret
    end

    def heading(_title) = nil
    def say(_message) = nil
    def capture(*) = ""
    def try(*) = true
    def ask_secret(_prompt) = @secret

    def run(*command, env: {}, **)
      @commands << command
      @envs << env
    end
  end

  def test_forgejo_login_hands_tea_the_pasted_token_outside_argv
    Dir.mktmpdir do |home|
      shell = RecordingShell.new(secret: "fat-mike-token")
      options = Bootstrap::Options.new(roles: %w[base])
      Bootstrap::Steps.new(config_root: home, options:, home:, shell:).send(:forgejo_login)

      login = shell.commands.index { it.first(3) == %w[tea login add] }
      refute_nil login
      assert_equal({"GITEA_SERVER_TOKEN" => "fat-mike-token"}, shell.envs[login])
      refute shell.commands[login].any? { it.include?("fat-mike-token") }
    end
  end

  def test_migrating_brings_jj_per_repo_config_along_with_the_repos
    Dir.mktmpdir do |home|
      shell = RecordingShell.new
      options = Bootstrap::Options.new(roles: %w[base dev], from: "thetis", developer: File.join(home, "Developer"))
      Bootstrap::Steps.new(config_root: home, options:, home:, shell:).send(:developer_dir)

      repos = File.join(home, ".config", "jj", "repos")
      assert_includes shell.commands, ["rsync", "-a", "thetis:.config/jj/repos/", "#{repos}/"]
      assert File.directory?(repos)
    end
  end

  # Answers as galiano would, and records what it was asked to try.
  class MudgeShell < RecordingShell
    attr_reader :tries

    def initialize
      super
      @tries = []
    end

    def capture(*) = "galiano"
    def pause(_message) = nil

    def try(*command, **)
      @tries << command
      true
    end
  end

  # The host report is every Mac's, so a Mac that only backs up needs the
  # token too: galiano was bootstrapped as backup-only and never sent one.
  def test_a_mac_that_only_backs_up_still_gets_the_report_token
    Dir.mktmpdir do |home|
      shell = MudgeShell.new
      developer = File.join(home, "Developer")
      FileUtils.mkdir_p([File.join(home, ".ssh"), File.join(developer, "mudge.samhuri.net", "clients", "mac", "folders.d")])
      %w[mudge-agent mudge-backup].each do |key|
        FileUtils.touch(File.join(home, ".ssh", key))
        File.write(File.join(home, ".ssh", "#{key}.pub"), "ssh-ed25519 AAAA #{key}@galiano\n")
      end
      options = Bootstrap::Options.new(roles: %w[base backup], developer:)
      Bootstrap::Steps.new(config_root: home, options:, home:, shell:).send(:mudge)

      assert shell.tries.any? { it.last.include?("report-token") }
    end
  end

  def test_skip_leaves_steps_out_and_refuses_unknown_ones
    refute_includes plan(roles: %w[base], skip: %w[forgejo apps]), "forgejo"
    error = assert_raises(Bootstrap::Error) { plan(roles: %w[base], skip: %w[kegerator]) }
    assert_includes error.message, "unknown step: kegerator"
  end
end
