# frozen_string_literal: true

module Bootstrap
  # zsh/zlocal is gitignored and sourced early by zshrc: the machine-specific
  # lines. A fresh Mac gets the two every Mac wants.
  module Zlocal
    CONTENT = <<~ZSH
      export PATH="$HOME/.local/bin:$PATH"

      # Skipped when the key is already loaded so new shells don't prompt.
      if [[ -r ~/.ssh/id_ed25519 ]]; then
          if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf ~/.ssh/id_ed25519.pub | awk '{print $2}')"; then
              ssh-add -q --apple-use-keychain ~/.ssh/id_ed25519
          fi
      fi
    ZSH

    def self.path(config_root:) = File.join(config_root, "zsh", "zlocal")
  end
end
