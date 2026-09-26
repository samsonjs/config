# frozen_string_literal: true

module Bootstrap
  # ~/.ssh/config is not in this repo (it names machine-local includes), so a
  # fresh Mac gets this one, and one that already has a config gets only the
  # mudge block if that is missing. `mudge` resolves through Tailscale's DNS.
  module SshConfig
    HEADER = <<~CONFIG
      Host *
          UseKeychain yes
          AddKeysToAgent yes
          IdentityFile ~/.ssh/id_ed25519
    CONFIG

    MUDGE = <<~CONFIG
      Host mudge
          User sjs
          ForwardAgent yes
    CONFIG

    def self.fresh = "#{HEADER}\n#{MUDGE}"

    # The text the file should hold after this run, or nil when it is already
    # fine.
    def self.updated(existing)
      return fresh if existing.nil?
      return nil if existing.match?(/^Host\s+mudge\b/)

      "#{existing.chomp}\n\n#{MUDGE}"
    end
  end
end
