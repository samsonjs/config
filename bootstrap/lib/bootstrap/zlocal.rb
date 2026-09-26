# frozen_string_literal: true

module Bootstrap
  # zsh/zlocal is gitignored and sourced early by zshrc: the machine-specific
  # lines. A fresh Mac gets the two every Mac wants.
  module Zlocal
    CONTENT = <<~ZSH
      export PATH="$HOME/.local/bin:$PATH"

      ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    ZSH

    def self.path(config_root:) = File.join(config_root, "zsh", "zlocal")
  end
end
