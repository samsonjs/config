# frozen_string_literal: true

require "rexml/document"

module Bootstrap
  Release = Data.define(:version, :url)

  # Just enough of a Sparkle appcast to find the newest full build: every item
  # carries an enclosure with the zip's URL, the version is either an
  # attribute on it (Sparkle 1) or a `sparkle:version` element on the item
  # (Sparkle 2, which is what generate_appcast writes), and deltas live under
  # sparkle:deltas rather than as items of their own.
  module Appcast
    def self.latest(xml)
      doc = REXML::Document.new(xml)
      releases = REXML::XPath.match(doc, "//item").filter_map do |item|
        enclosure = REXML::XPath.first(item, "enclosure")
        next unless enclosure

        version = enclosure.attributes["sparkle:version"] || REXML::XPath.first(item, "sparkle:version")&.text
        url = enclosure.attributes["url"]
        Release.new(version:, url:) if version && url
      end
      raise Error, "no releases in appcast" if releases.empty?

      releases.max_by { Gem::Version.new(it.version) }
    end
  end
end
