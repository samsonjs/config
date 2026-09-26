# frozen_string_literal: true

module Bootstrap
  # A Claude Code skill in its own repo: linked into ~/.claude/skills as `name`,
  # from `path` inside the checkout ("." for the root).
  Skill = Data.define(:name, :url, :path) do
    def checkout(developer:) = File.join(developer, File.basename(url, ".git"))

    def source(developer:)
      path == "." ? checkout(developer:) : File.join(checkout(developer:), path)
    end
  end

  Repo = Data.define(:url) do
    def name = File.basename(url, ".git")
    def checkout(developer:) = File.join(developer, name)
  end

  # One of my own apps, published to mudge's Sparkle feed.
  App = Data.define(:name) do
    def feed = name.downcase
    def bundle = "#{name}.app"
    def appcast_url(feed_base:) = "#{feed_base}/#{feed}/appcast.xml"
  end

  # The line-oriented lists at the repo root and under roles/: blank lines and
  # `#` comments are ignored, fields are whitespace-separated.
  module Manifest
    def self.lines(text)
      text.lines(chomp: true).map { it.sub(/#.*/, "").strip }.reject(&:empty?)
    end

    def self.skills(text)
      lines(text).map do |line|
        name, url, path = line.split(/\s+/, 3)
        raise Error, "skills: expected `name url path`, got: #{line}" if url.nil? || path.nil?

        Skill.new(name:, url:, path:)
      end
    end

    def self.repos(text) = lines(text).map { Repo.new(url: it) }

    def self.apps(text) = lines(text).map { App.new(name: it) }

    # The shared Brewfile plus one per role that has one, in role order.
    def self.brewfiles(roles, root:)
      [File.join(root, "Brewfile")] +
        roles.map { File.join(root, "roles", it, "Brewfile") }.select { File.exist?(it) }
    end

    def self.mas?(brewfile_text) = brewfile_text.lines.any? { it.match?(/\A\s*mas\b/) }
  end
end
