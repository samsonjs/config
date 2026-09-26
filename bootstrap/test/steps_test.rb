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

  def test_skip_leaves_steps_out_and_refuses_unknown_ones
    refute_includes plan(roles: %w[base], skip: %w[forgejo apps]), "forgejo"
    error = assert_raises(Bootstrap::Error) { plan(roles: %w[base], skip: %w[kegerator]) }
    assert_includes error.message, "unknown step: kegerator"
  end
end
