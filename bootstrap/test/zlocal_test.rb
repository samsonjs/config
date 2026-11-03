# frozen_string_literal: true

require_relative "test_helper"

class ZlocalTest < Minitest::Test
  def setup
    skip "needs zsh" unless system("command -v zsh", out: File::NULL)
  end

  # ssh-add and ssh-keygen are stubbed so this runs without an agent or
  # OpenSSH; the stub agent holds the key when `loaded` is true.
  def ssh_add_calls(loaded:)
    Dir.mktmpdir do |home|
      FileUtils.mkdir_p(File.join(home, ".ssh"))
      FileUtils.touch(%w[id_ed25519 id_ed25519.pub].map { File.join(home, ".ssh", it) })
      bin = File.join(home, "bin")
      FileUtils.mkdir_p(bin)
      listing = "256 SHA256:fakeprint sjs@galiano (ED25519)"
      File.write(File.join(bin, "ssh-keygen"), "#!/bin/sh\necho '#{listing}'\n")
      File.write(File.join(bin, "ssh-add"), <<~SH)
        #!/bin/sh
        if [ "$1" = -l ]; then
          #{loaded ? "echo '#{listing}'; exit 0" : "echo 'The agent has no identities.'; exit 1"}
        fi
        echo "$@" >> "$HOME/ssh-add.log"
      SH
      File.chmod(0o755, *Dir[File.join(bin, "*")])
      zlocal = File.join(home, "zlocal")
      File.write(zlocal, Bootstrap::Zlocal::CONTENT)

      env = {"HOME" => home, "PATH" => "#{bin}:/usr/bin:/bin"}
      assert system(env, "zsh", "-f", "-c", "source #{zlocal}"), "zlocal failed to source"
      log = File.join(home, "ssh-add.log")
      File.exist?(log) ? File.readlines(log, chomp: true).map { it.sub(home, "~") } : []
    end
  end

  def test_a_new_shell_loads_the_key_when_the_agent_does_not_have_it
    assert_equal ["-q --apple-use-keychain ~/.ssh/id_ed25519"], ssh_add_calls(loaded: false)
  end

  def test_a_new_shell_leaves_an_already_loaded_key_alone
    assert_empty ssh_add_calls(loaded: true)
  end
end
