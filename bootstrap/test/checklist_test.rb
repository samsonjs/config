# frozen_string_literal: true

require_relative "test_helper"

class ChecklistTest < Minitest::Test
  def test_items_are_numbered_once_each
    list = Bootstrap::Checklist.new
    assert_equal "Nothing left to do by hand.\n", list.render
    list.add("Sign in to Tailscale.")
    list.add("Sign in to Tailscale.")
    list.add("Grant Full Disk Access.")
    assert_equal "Still yours to do by hand:\n  1. Sign in to Tailscale.\n  2. Grant Full Disk Access.\n", list.render
  end
end
