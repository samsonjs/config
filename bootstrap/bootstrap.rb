#!/usr/bin/env ruby
# frozen_string_literal: true

# Stage two of bootstrap.sh; see ../Readme.md. Run it again any time.
$LOAD_PATH.unshift(File.join(__dir__, "lib"))
require "bootstrap"

exit Bootstrap::CLI.run(ARGV, config_root: File.expand_path("..", __dir__))
