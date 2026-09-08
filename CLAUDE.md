# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles configuration repository containing shell configurations, editor settings, git configuration, and development tools setup for macOS and Unix systems.

## Setup and Installation

The main setup script is `init.sh`. Run it to symlink configuration files to their proper locations:

```bash
./init.sh
```

This script:
- Creates symlinks from files in this repo to `~/.filename`
- Backs up existing dotfiles to `~/original-dot-files/`
- Excludes certain files (init.sh, Gemfile, Gemfile.lock, zsh/, Brewfile)

## Package Management

Install development tools and applications using Homebrew:

```bash
brew bundle install
```

The `Brewfile` contains essential development tools like:
- CLI tools: gh, jq, ripgrep, terraform, awscli
- Development environments: rbenv/rv, direnv
- Utilities: diff-so-fancy, parallel, llm

## Shell Configuration

This config is shared across many machines and operating systems. Tool blocks in `zshrc` are guarded with `command_exists` so one file works everywhere; never remove one because a tool isn't installed on the current machine. Machine-local settings belong in `zsh/zlocal`, which is gitignored.

The zsh configuration is modular and located in:
- Main config: `zshrc`
- Functions: `zsh/functions/`
- Completions: `zsh/completions/`
- Device control utilities: `zsh/devicectl.sh`

Key features:
- Custom prompt with git integration (`prompt sjs`)
- Extensive git aliases (a, c, co, d, s, etc.)
- Smart directory navigation with auto-cd
- History management with 2M line buffer
- Ruby/rbenv/rv and Python/pyenv integration
- iOS device control functions via `devicectl.sh`

Notable aliases:
- `cc` = `claude --dangerously-skip-permissions` (Claude Code)
- `be` = `bundle exec`
- `doc` = `docker-compose`

## Editor Configurations

### Emacs (`emacs` file)
- Comprehensive Emacs configuration with language-specific modes
- Custom key bindings optimized for macOS
- Support for Ruby, JavaScript, Python, C, Haskell, Lisp
- TextMate-style project navigation
- Custom themes and visual settings

### Vim (`vimrc` file)
- Dark theme with syntax highlighting
- 4-space indentation with smart tabbing
- Folding support with marker-based folds
- Language-specific auto-commands for C, Python, PHP, etc.
- Custom key mappings for buffer navigation

## Git Configuration

The `gitconfig` contains:
- Signed commits with SSH keys
- Enhanced diff output with `diff-so-fancy`
- Automatic rebase and fast-forward-only pulls
- Advanced merge and diff algorithms
- Pre-commit hook that runs `git diff --check`

### Commit signing (git and jj)

Both git and jj sign commits with SSH keys and verify against the tracked `allowed_signers` file (principal `sami@samhuri.net`, one line per public key). The synced defaults assume the conventional key: git signs with `~/.ssh/id_ed25519` (`signingKey` in `gitconfig`) and jj with `~/.ssh/id_ed25519.pub`. jj signs on push (`git.sign-on-push` in `jj/config.toml`) rather than on every rewrite, so unpushed changes show no signature.

A machine that signs with a different key overrides that in its local files, which are gitignored and win over the synced config:

- git: `~/config/gitconfig-local`, included last by `gitconfig`. Template: `gitconfig-local.example`.
- jj: `~/.config/jj/conf.d/local.toml`. Template: `jj/local.toml.example`.

`init.sh` copies each template into place when the local file is missing and never overwrites it. The templates carry commented examples for a key held in 1Password (the public key literal plus `op-ssh-sign` as the ssh signing program) and for a dedicated key file such as `~/.ssh/forgejo`.

Whichever key a machine signs with, its public half must be in `allowed_signers`, committed and pulled everywhere, or its signatures verify as `unknown`. Check with `git log -1 --show-signature` or, after a push, `jj log -r main --no-graph -T 'signature.status()'`.

## Global Claude Code instructions

The global `~/.claude/CLAUDE.md` is shared across machines through `claude/CLAUDE.md` in this repo. It can't live at the repo root, because the `CLAUDE.md` there is this repo's own instructions.

`~/.claude/CLAUDE.md` itself is a small real file that imports both halves:

```
@~/config/claude/CLAUDE.md
@~/.claude/CLAUDE.local.md
```

`init.sh` creates it from `claude/CLAUDE.md.example` when missing, rewriting the import to point at this checkout, and never overwrites an existing one. `~/.claude/CLAUDE.local.md` is untracked and imported last, so machine-specific guidance wins over the shared file — that's where the work Mac keeps its work-only content. A missing import is ignored without error, so no placeholder is needed — which also means a wrong path leaves you with no shared instructions and no complaint, so check it if you place the stub by hand.

Migrating a machine that still has its own full `~/.claude/CLAUDE.md` is a deliberate manual step, not something `init.sh` does: move the old file aside, run `init.sh` to drop in the stub, then diff the backup against `claude/CLAUDE.md` and put anything genuinely machine-specific into `~/.claude/CLAUDE.local.md` before deleting it. What belongs in the local file is a judgement call, so it isn't automated.

It is deliberately **not** a symlink. Claude Code's file-editing tools refuse to write through a symlink ("Refusing to write ...: it is a symbolic link"), so a symlinked `~/.claude/CLAUDE.md` could never be updated in place. The import stub keeps all three files writable while leaving the shared content tracked here. Note also that an atomic-save editor (write to temp, rename over) silently replaces a symlink with a regular file, which is how the previous iCloud arrangement came apart.

## iOS Development Tools

The `zsh/devicectl.sh` provides functions for iOS device management:
- `devicepid <device> <process>` - Find process PID on device
- `devicekill <device> <process>` - Kill process on device
- `respring <device>` - Restart SpringBoard
- `devicereboot <device>` - Reboot device

## File Structure

Key configuration mappings:
- `zshrc` → `~/.zshrc`
- `vimrc` → `~/.vimrc`
- `emacs` → `~/.emacs`
- `gitconfig` → `~/.gitconfig`
- `gitignore` → `~/.gitignore` (global)
- `irbrc` → `~/.irbrc`
- `gemrc` → `~/.gemrc`
- `ackrc` → `~/.ackrc`
- `claude/CLAUDE.md` → imported by `~/.claude/CLAUDE.md` (not symlinked, see above)

## Development Workflow

When making changes:
1. Edit files directly in this repository
2. Test changes by sourcing or reloading configs
3. Commit changes with descriptive messages
4. The pre-commit hook will check for whitespace issues

The configuration supports both macOS and Linux environments with platform-specific adaptations throughout the shell and editor configs.