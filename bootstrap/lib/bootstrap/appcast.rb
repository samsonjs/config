# frozen_string_literal: true

require "rexml/document"

module Bootstrap
  Release = Data.define(:version, :url)

  # Just enough of a Sparkle appcast to find the newest full build: every item
  # carries an enclosure with the zip's URL and sparkle:version, and deltas
  # live under sparkle:deltas rather than as items of their own.
  module Appcast
    def self.latest(xml)
      doc = REXML::Document.new(xml)
      releases = REXML::XPath.match(doc, "//item/enclosure").filter_map do |enclosure|
        version = enclosure.attributes["sparkle:version"]
        url = enclosure.attributes["url"]
        Release.new(version:, url:) if version && url
      end
      raise Error, "no releases in appcast" if releases.empty?

      releases.max_by { Gem::Version.new(it.version) }
    end
  end
end
