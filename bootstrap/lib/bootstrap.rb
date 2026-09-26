# frozen_string_literal: true

# Stage two of bootstrapping a Mac. bootstrap.sh at the repo root gets a fresh
# machine as far as Homebrew, git, jj, rv and a clone of this repo, then hands
# over to this. Everything here is idempotent and safe to re-run.
module Bootstrap
  class Error < StandardError; end
end

require_relative "bootstrap/roles"
require_relative "bootstrap/manifest"
require_relative "bootstrap/appcast"
require_relative "bootstrap/ssh_config"
require_relative "bootstrap/zlocal"
require_relative "bootstrap/checklist"
require_relative "bootstrap/shell"
require_relative "bootstrap/steps"
require_relative "bootstrap/cli"
