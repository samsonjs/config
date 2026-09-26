# frozen_string_literal: true

require_relative "test_helper"

class RolesTest < Minitest::Test
  def test_base_is_always_present_and_order_is_fixed
    assert_equal %w[base dev backup], Bootstrap::Roles.parse("backup, dev")
    assert_equal %w[base], Bootstrap::Roles.parse("")
    assert_equal %w[base ci-runner], Bootstrap::Roles.parse(["ci-runner", "base"])
  end

  def test_an_unknown_role_is_refused_by_name
    error = assert_raises(Bootstrap::Error) { Bootstrap::Roles.parse("dev,kegerator") }
    assert_includes error.message, "unknown role: kegerator"
  end

  def test_the_file_round_trips_and_ignores_comments
    Dir.mktmpdir do |dir|
      path = File.join(dir, ".config", "deriva", "roles")
      assert_nil Bootstrap::Roles.read(path)
      Bootstrap::Roles.write("archivist,dev", path)
      assert_equal "base\ndev\narchivist\n", File.read(path)
      File.write(path, "# galiano\nbase\ndev\n")
      assert_equal %w[base dev], Bootstrap::Roles.read(path)
    end
  end

  def test_the_mudge_roles_map_to_install_sh_components
    assert_equal %w[runner backup], Bootstrap::Roles.mudge_components(%w[base ci-runner backup])
    assert_empty Bootstrap::Roles.mudge_components(%w[base dev])
  end
end
