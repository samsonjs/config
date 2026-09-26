# frozen_string_literal: true

module Bootstrap
  # What the run could not do itself: sign-ins, TCC grants, keys to register
  # elsewhere. Collected as the steps go and printed once at the end, so the
  # things left to do by hand are in one place rather than scrolled away.
  class Checklist
    def initialize
      @items = []
    end

    def add(item)
      @items << item unless @items.include?(item)
    end

    def empty? = @items.empty?

    def render
      return "Nothing left to do by hand.\n" if empty?

      lines = ["Still yours to do by hand:"]
      @items.each_with_index { |item, i| lines << "  #{i + 1}. #{item}" }
      "#{lines.join("\n")}\n"
    end
  end
end
