# frozen_string_literal: true

require_relative "test_helper"

class ManifestTest < Minitest::Test
  SKILLS = <<~TEXT
    # name  repo  path
    jujutsu   https://git.samhuri.net/sjs/jujutsu-skill.git   jujutsu

    messaging https://git.samhuri.net/sjs/claude-code-messaging.git .  # root
  TEXT

  def test_skills_know_their_checkout_and_source
    jujutsu, messaging = Bootstrap::Manifest.skills(SKILLS)
    assert_equal "jujutsu", jujutsu.name
    assert_equal "/dev/jujutsu-skill", jujutsu.checkout(developer: "/dev")
    assert_equal "/dev/jujutsu-skill/jujutsu", jujutsu.source(developer: "/dev")
    assert_equal "/dev/claude-code-messaging", messaging.source(developer: "/dev")
  end

  def test_a_skill_line_missing_a_field_is_an_error
    assert_raises(Bootstrap::Error) { Bootstrap::Manifest.skills("jujutsu https://example.net/x.git") }
  end

  def test_repos_and_apps
    repo = Bootstrap::Manifest.repos("https://git.samhuri.net/sjs/vortex.git\n").first
    assert_equal "vortex", repo.name
    app = Bootstrap::Manifest.apps("# mine\nImpRAMta\n").first
    assert_equal "impramta", app.feed
    assert_equal "ImpRAMta.app", app.bundle
    assert_equal "http://mudge:8787/impramta/appcast.xml", app.appcast_url(feed_base: "http://mudge:8787")
  end

  def test_brewfiles_are_the_shared_one_plus_each_role_that_has_one
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "roles", "dev"))
      File.write(File.join(root, "Brewfile"), "brew 'jj'\n")
      File.write(File.join(root, "roles", "dev", "Brewfile"), "mas 'TestFlight', id: 899247664\n")
      files = Bootstrap::Manifest.brewfiles(%w[base dev backup], root:)
      assert_equal [File.join(root, "Brewfile"), File.join(root, "roles", "dev", "Brewfile")], files
      refute Bootstrap::Manifest.mas?(File.read(files[0]))
      assert Bootstrap::Manifest.mas?(File.read(files[1]))
    end
  end
end
