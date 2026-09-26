# frozen_string_literal: true

module Bootstrap
  Role = Data.define(:name, :summary)

  # What a Mac is for. Recorded on the machine, not in this repo: which roles a
  # box carries is a fact about that box, like its hostname, and Deriva reads
  # the same file to decide which Brewfiles to reconcile.
  module Roles
    ALL = [
      Role.new(name: "base", summary: "shell, Homebrew, apps, macOS settings, Deriva (every Mac)"),
      Role.new(name: "dev", summary: "Xcode, dev tools, Claude Code, skills, repos in ~/Developer"),
      Role.new(name: "ci-runner", summary: "the Forgejo Actions runner (mudge's runner component)"),
      Role.new(name: "backup", summary: "hourly backup to mudge (mudge's backup component)"),
      Role.new(name: "archivist", summary: "Notes, Reminders and Photos archiving for vortex")
    ].freeze
    NAMES = ALL.map(&:name).freeze

    # Roles that are really mudge Mac components, by the name install.sh takes.
    MUDGE_COMPONENTS = {"ci-runner" => "runner", "backup" => "backup"}.freeze

    def self.file(home: Dir.home) = File.join(home, ".config", "deriva", "roles")

    # "dev,backup" or ["dev", "backup"] -> ["base", "dev", "backup"], in ALL's
    # order, with base always present since every Mac carries it.
    def self.parse(input)
      names = Array(input).flat_map { it.to_s.split(/[\s,]+/) }.reject(&:empty?)
      unknown = names - NAMES
      raise Error, "unknown role#{"s" if unknown.size > 1}: #{unknown.join(", ")} (one of #{NAMES.join(", ")})" unless unknown.empty?

      NAMES & (["base"] + names)
    end

    def self.read(path)
      return nil unless File.exist?(path)

      parse(File.readlines(path, chomp: true).map { it.sub(/#.*/, "").strip })
    end

    def self.write(names, path)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "#{parse(names).join("\n")}\n")
    end

    def self.mudge_components(names) = MUDGE_COMPONENTS.values_at(*names).compact
  end
end
