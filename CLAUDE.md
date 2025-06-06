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
- Development environments: rbenv, direnv
- Utilities: diff-so-fancy, parallel, llm

## Shell Configuration

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
- Ruby/rbenv and Python/pyenv integration
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

## Development Workflow

When making changes:
1. Edit files directly in this repository
2. Test changes by sourcing or reloading configs
3. Commit changes with descriptive messages
4. The pre-commit hook will check for whitespace issues

The configuration supports both macOS and Linux environments with platform-specific adaptations throughout the shell and editor configs.