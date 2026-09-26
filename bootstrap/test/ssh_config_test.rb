# frozen_string_literal: true

require_relative "test_helper"

class SshConfigTest < Minitest::Test
  def test_a_fresh_mac_gets_the_whole_file
    text = Bootstrap::SshConfig.updated(nil)
    assert_includes text, "Host *\n    UseKeychain yes"
    assert_includes text, "Host mudge\n    User sjs"
  end

  def test_an_existing_config_only_gains_the_mudge_host
    existing = "Include ~/.orbstack/ssh/config\n\nHost *\n    IdentityFile ~/.ssh/id_ed25519\n"
    text = Bootstrap::SshConfig.updated(existing)
    assert text.start_with?(existing)
    assert_includes text, "\n\nHost mudge\n"
  end

  def test_a_config_that_already_names_mudge_is_left_alone
    assert_nil Bootstrap::SshConfig.updated("Host mudge\n    User sjs\n")
  end
end
