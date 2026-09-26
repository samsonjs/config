# frozen_string_literal: true

require "optparse"
require "shellwords"

module Bootstrap
  module CLI
    def self.run(argv, config_root:)
      roles = nil
      from = nil
      developer = File.join(Dir.home, "Developer")

      parser = OptionParser.new do |o|
        o.banner = "usage: bootstrap.sh [--roles dev,backup] [--from HOST]"
        o.on("--roles LIST", "comma-separated roles (base is implied); asked for if omitted") { roles = it }
        o.on("--from HOST", "migrate: rsync ~/Developer and my apps from HOST instead of cloning and downloading") { from = it }
        o.on("--developer DIR", "where repos go (default #{developer})") { developer = it }
        o.on("--list-roles", "show the roles and exit") do
          Roles::ALL.each { puts "  #{it.name.ljust(10)} #{it.summary}" }
          return 0
        end
      end
      parser.parse!(argv)

      recorded = Roles.read(Roles.file)
      roles = Roles.parse(roles || recorded || ask_roles)
      options = Options.new(roles:, from:, developer:)
      Steps.new(config_root:, options:).run
      0
    rescue Error => e
      warn "bootstrap: #{e.message}"
      1
    end

    def self.ask_roles
      Shell.say("Which roles does this Mac carry? (base is always on)")
      Roles::ALL.each { Shell.say("  #{it.name.ljust(10)} #{it.summary}") }
      Shell.ask("Roles, comma-separated:")
    end
  end
end
