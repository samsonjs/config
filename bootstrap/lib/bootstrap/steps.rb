# frozen_string_literal: true

require "fileutils"
require "net/http"
require "shellwords"
require "tmpdir"
require "uri"

module Bootstrap
  Options = Data.define(:roles, :from, :developer) do
    def migrating? = !from.nil?
  end

  # The steps themselves, in the order they run. Each is idempotent: it checks
  # before it acts, and adds to the checklist what only a person can do.
  class Steps
    FEED_BASE = "http://mudge:8787"
    TAILSCALE = "/Applications/Tailscale.app/Contents/MacOS/Tailscale"

    attr_reader :checklist

    def initialize(config_root:, options:, home: Dir.home, shell: Shell)
      @config_root = config_root
      @options = options
      @home = home
      @shell = shell
      @checklist = Checklist.new
    end

    def run
      roles = @options.roles
      record_roles
      init_sh
      zlocal
      ssh
      forgejo_login
      brew_bundle
      macos_defaults
      own_apps
      if roles.include?("dev")
        developer_dir
        skills
        init_sh
        macapp_tools
        claude_code
        xcode
      end
      mudge unless Roles.mudge_components(roles).empty?
      archivist if roles.include?("archivist")
      launch_deriva
      @shell.say("\n#{@checklist.render}")
    end

    private

    def home(*parts) = File.join(@home, *parts)
    def config(*parts) = File.join(@config_root, *parts)
    def developer(*parts) = File.join(@options.developer, *parts)
    def role?(name) = @options.roles.include?(name)

    def hostname
      @hostname ||= @shell.capture("scutil", "--get", "LocalHostName").downcase
    end

    # --- base -----------------------------------------------------------------

    def record_roles
      @shell.heading("Roles: #{@options.roles.join(", ")}")
      Roles.write(@options.roles, Roles.file(home: @home))
      @shell.say("→ Recorded in #{Roles.file(home: @home)}")
    end

    def init_sh
      @shell.heading("Dotfiles")
      @shell.run(config("init.sh"))
    end

    def zlocal
      path = Zlocal.path(config_root: @config_root)
      return if File.exist?(path)

      File.write(path, Zlocal::CONTENT)
      @shell.say("→ Created #{path}")
    end

    def ssh
      @shell.heading("SSH")
      ssh_dir = home(".ssh")
      FileUtils.mkdir_p(ssh_dir, mode: 0o700)

      config_path = File.join(ssh_dir, "config")
      existing = File.exist?(config_path) ? File.read(config_path) : nil
      if (text = SshConfig.updated(existing))
        File.write(config_path, text)
        File.chmod(0o600, config_path)
        @shell.say("→ #{existing ? "Added the mudge host to" : "Wrote"} #{config_path}")
      end

      key = File.join(ssh_dir, "id_ed25519")
      unless File.exist?(key)
        # One key per Mac, for auth on Forgejo and GitHub and for signing
        # commits; allowed_signers lists every Mac's. Interactive on purpose so
        # it gets a passphrase, which the keychain then remembers.
        @shell.run("ssh-keygen", "-t", "ed25519", "-C", "#{ENV.fetch("USER")}@#{hostname}", "-f", key)
      end
      @shell.try("ssh-add", "--apple-use-keychain", key)

      public_key = File.read("#{key}.pub").strip
      allowed = config("allowed_signers")
      type, blob = public_key.split(" ")
      unless File.read(allowed).include?(blob)
        File.write(allowed, "#{git_email} #{type} #{blob}\n", mode: "a")
        @shell.say("→ Added this Mac's key to #{allowed}")
        @checklist.add("Describe and push the allowed_signers change in ~/config so other Macs verify this one's signatures.")
      end

      @shell.say("\nThis Mac's public key:\n\n  #{public_key}\n")
      @shell.pause(<<~MSG)
        Add it on Forgejo (https://git.samhuri.net/user/settings/keys) as an SSH key AND
        as a signing key, and on GitHub (https://github.com/settings/keys) likewise.
      MSG
    end

    def git_email
      @git_email ||= @shell.capture("git", "config", "--get", "user.email")
    end

    def forgejo_login
      @shell.heading("Forgejo")
      if @shell.capture("tea", "logins", "list").include?("git.samhuri.net")
        @shell.say("✓ tea is logged in to git.samhuri.net")
      else
        @shell.say("tea will ask for a token: create one at https://git.samhuri.net/user/settings/applications")
        @shell.run("tea", "login", "add", "--name", "mudge", "--url", "https://git.samhuri.net", "--git-credentials")
      end
      return unless role?("dev")

      if @shell.try("gh", "auth", "status")
        @shell.say("✓ gh is logged in")
      else
        @shell.run("gh", "auth", "login")
      end
    end

    def brew_bundle
      @shell.heading("Homebrew")
      files = Manifest.brewfiles(@options.roles, root: @config_root)
      if files.any? { Manifest.mas?(File.read(it)) }
        @shell.pause("Sign in to the App Store (open it and sign in) so mas can install apps.")
      end
      files.each { @shell.run("brew", "bundle", "install", "--file", it) }
    end

    def macos_defaults
      @shell.heading("macOS settings")
      @shell.run("zsh", config("macos", "defaults.sh"))
      @shell.run("zsh", config("macos", "import-defaults.sh"))
      @checklist.add("Log out and back in for the macOS settings to take effect.")
    end

    def own_apps
      @shell.heading("My apps")
      apps = Manifest.apps(File.read(config("apps")))
      apps.each do |app|
        target = File.join("/Applications", app.bundle)
        if File.exist?(target)
          @shell.say("✓ #{app.bundle} is installed")
        elsif @options.migrating?
          @shell.run("rsync", "-a", "#{@options.from}:/Applications/#{app.bundle}/", "#{target}/")
        else
          install_from_feed(app, target)
        end
      end
    end

    def install_from_feed(app, target)
      xml = fetch(app.appcast_url(feed_base: FEED_BASE))
      unless xml
        @shell.say("… #{app.name}: mudge's feed is not reachable (Tailscale?)")
        @checklist.add("Join the tailnet and re-run bootstrap.sh to install #{app.name}.")
        return
      end
      release = Appcast.latest(xml)
      Dir.mktmpdir("bootstrap-#{app.feed}") do |dir|
        zip = File.join(dir, "#{app.feed}.zip")
        @shell.run("curl", "-fsSL", "-o", zip, release.url, quiet: true)
        @shell.run("ditto", "-x", "-k", zip, dir, quiet: true)
        bundle = Dir.glob(File.join(dir, "**", app.bundle)).first
        raise Error, "#{release.url} did not contain #{app.bundle}" unless bundle

        FileUtils.mv(bundle, target)
      end
      @shell.say("→ Installed #{app.name} #{release.version}")
    end

    def fetch(url)
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, open_timeout: 3, read_timeout: 10) do |http|
        response = http.get(uri.path)
        response.is_a?(Net::HTTPSuccess) ? response.body : nil
      end
    rescue SystemCallError, Net::OpenTimeout, Net::ReadTimeout, SocketError
      nil
    end

    def launch_deriva
      app = "/Applications/Deriva.app"
      return unless File.exist?(app)

      @shell.try("open", "-a", app)
      @checklist.add("Turn on Launch at Login in Deriva's menu bar panel.")
    end

    # --- dev ------------------------------------------------------------------

    def developer_dir
      @shell.heading("~/Developer")
      FileUtils.mkdir_p(@options.developer)
      if @options.migrating?
        # As-is, working copies and all: a clone would lose what isn't pushed.
        @shell.run("rsync", "-a", "--info=progress2", "--exclude", ".DS_Store", "#{@options.from}:Developer/", "#{@options.developer}/")
        return
      end
      Manifest.repos(File.read(config("roles", "dev", "repos"))).each { clone(it.url, it.checkout(developer: @options.developer)) }
    end

    def skills
      @shell.heading("Skills")
      Manifest.skills(File.read(config("skills"))).each { clone(it.url, it.checkout(developer: @options.developer)) }
    end

    def clone(url, checkout)
      if File.directory?(checkout)
        @shell.say("✓ #{checkout}")
      else
        @shell.run("jj", "git", "clone", "--colocate", url, checkout)
      end
    end

    def macapp_tools
      root = developer("macapp-tools")
      return unless File.directory?(root)

      @shell.heading("macapp-tools")
      version = File.read(File.join(root, ".ruby-version")).strip
      @shell.run("rv", "ruby", "install", "--quiet", version) unless @shell.try("rv", "ruby", "find", version)
      ruby = @shell.capture("rv", "ruby", "find", version)
      bundle = File.join(File.dirname(ruby), "bundle")
      @shell.run(ruby, bundle, "install", "--quiet", chdir: root)
      @shell.run(ruby, bundle, "exec", "rake", "install", chdir: root)
    end

    def claude_code
      @shell.heading("Claude Code")
      if File.exist?(home(".local", "bin", "claude"))
        @shell.say("✓ installed")
      else
        @shell.run("bash", "-c", "curl -fsSL https://claude.ai/install.sh | bash")
      end
      @checklist.add("Run `claude` once to sign in.")
    end

    def xcode
      @checklist.add("Open Xcodes, install the current Xcode, then `sudo xcode-select -s /Applications/Xcode-<version>.app`.")
      @checklist.add("Install FlowDeck and its CLI if this Mac does iOS work.")
    end

    # --- mudge ----------------------------------------------------------------

    def mudge
      components = Roles.mudge_components(@options.roles)
      @shell.heading("mudge (#{components.join(", ")})")
      until @shell.try(TAILSCALE, "status")
        @shell.pause("Open Tailscale and sign in; mudge is only reachable on the tailnet.")
      end

      checkout = developer("mudge.samhuri.net")
      clone("https://git.samhuri.net/sjs/mudge.samhuri.net.git", checkout)

      agent_key = home(".ssh", "mudge-agent")
      keygen(agent_key, "mudge-agent@#{hostname}")
      @shell.pause(<<~MSG)
        Add #{agent_key}.pub as a READ-ONLY deploy key on
        https://git.samhuri.net/sjs/mudge.samhuri.net/settings/keys:

          #{File.read("#{agent_key}.pub").strip}
      MSG

      if components.include?("backup")
        backup_key = home(".ssh", "mudge-backup")
        keygen(backup_key, "mudge-backup@#{hostname}")
        ip = @shell.capture(TAILSCALE, "ip", "-4")
        @shell.pause(<<~MSG)
          On mudge, append this line to ~/.ssh/authorized_keys:

            from="#{ip}",restrict #{File.read("#{backup_key}.pub").strip}
        MSG
        folders = File.join(checkout, "clients", "mac", "folders.d", "#{hostname}.txt")
        unless File.exist?(folders)
          File.write(folders, "# Path list for #{hostname}; its presence enables backups here.\n/Users/#{ENV.fetch("USER")}\n")
          @checklist.add("Describe and push clients/mac/folders.d/#{hostname}.txt in ~/Developer/mudge.samhuri.net; backups start once it is on main.")
        end
      end

      @shell.run(File.join(checkout, "clients", "mac", "install.sh"), "--components", components.join(","))

      if components.include?("runner")
        token_dir = home("Library", "Application Support", "mudge-report")
        FileUtils.mkdir_p(token_dir)
        token = File.join(token_dir, "token")
        unless File.exist?(token) || @shell.try("bash", "-c", "ssh mudge sudo cat /var/lib/mudge-dashboard/report-token > #{token.shellescape}")
          @checklist.add("Copy mudge's report token: ssh mudge sudo cat /var/lib/mudge-dashboard/report-token > \"#{token}\"")
        end
        @checklist.add("Register the Actions runner: ~/mudge.samhuri.net/clients/mac/install-runner.sh --token \"$(tea api /user/actions/runners/registration-token | jq -r .token)\"")
      end
      if components.include?("backup")
        @checklist.add("Grant Full Disk Access to ~/mudge.samhuri.net/clients/mac/mudge-backup.sh (System Settings → Privacy & Security).")
      end
    end

    def keygen(path, comment)
      return if File.exist?(path)

      # Unattended daemons can't answer a passphrase prompt.
      @shell.run("ssh-keygen", "-t", "ed25519", "-N", "", "-C", comment, "-f", path)
    end

    # --- archivist ------------------------------------------------------------

    def archivist
      @shell.heading("Archivist")
      checkout = developer("vortex")
      clone("https://git.samhuri.net/sjs/vortex.git", checkout)
      @shell.run(File.join(checkout, "script", "bootstrap"), chdir: checkout)
      @checklist.add("Photos → Settings → iCloud: Download Originals to this Mac.")
      @checklist.add("Grant Full Disk Access to the terminal app vortex runs from, for Apple Notes.")
      @checklist.add("Run `remctl onboard` so vortex can read Reminders.")
    end
  end
end
