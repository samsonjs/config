# sjs's config (dotfiles)

These are my personal *nix config files, hand-crafted since around 2004 when I started by pilfering everything I could find on mailing lists and blogs. They work great on both Linux and macOS, with more server-ish stuff on the Linux side and desktop-ish stuff on the macOS side.

After zsh (big time zsh hipster) this is the first thing I set up in my shell environment on a new machine, along with [~/bin](https://github.com/samsonjs/bin).

## what've we got here?

- **zsh**: custom prompt with git integration, extensive aliases, lots of nitpicky tweaks like subword navigation excluding / for easy subpath traversal
- **$EDITOR**: vim and emacs configs, though the emacs one is fairly dated
- **git**: enhanced diffing, signed commits, pre-commit hooks
- **ruby**: rbenv/rv integration, IRB customizations
- **screen**: yep I'm old, no tmux here
- **iOS simulator stuff**: [device control utilities](https://gist.github.com/insidegui/b570ec998b9e2aeb730f4e142f0593d1) via `devicectl.sh` (from Gui Rambo)

## setting up a new Mac

One line in Terminal on the new machine does everything this repo knows how to do:

```zsh
bash -c "$(curl -fsSL https://git.samhuri.net/sjs/config/raw/branch/main/bootstrap.sh)"
```

`bootstrap.sh` installs the Command Line Tools, Homebrew, git, jj and rv, clones this repo and [~/bin](https://git.samhuri.net/sjs/bin) over HTTPS, and hands over to `bootstrap/bootstrap.rb`, which asks which roles the Mac carries and then works through them: `init.sh`, an SSH key (it pauses while you register it), `tea login`, `brew bundle` from the `Brewfile` plus each role's, the macOS settings, my own apps from mudge's feed, and for the dev role Xcodes, the repos in `roles/dev/repos`, the skills in `skills`, macapp-tools and Claude Code. The mudge roles hand off to `mudge.samhuri.net/clients/mac/install.sh`. It ends with a numbered list of what only a person can do (sign-ins, Full Disk Access, keys to paste elsewhere).

The roles are `base` (always), `dev`, `ci-runner`, `backup` and `archivist`; `bootstrap.sh -- --list-roles` describes them. The choice is recorded in `~/.config/deriva/roles`, on the machine rather than in this repo, and Deriva reads the same file.

Every step checks before it acts, so re-running is the way to pick up where a pause left off:

```zsh
~/config/bootstrap.sh                    # again, with the recorded roles
~/config/bootstrap.sh --roles dev,backup # or a different set
~/config/bootstrap.sh --from thetis      # migrating: rsync ~/Developer and my apps from the old Mac
```

`brew bundle` refuses to install a cask over an app that was dragged in by hand; on a Mac like that, adopt the ones already present first: `brew install --cask --adopt acorn bbedit …`.

## setup by hand

All files in this repo are symlinked to `~/.filename`. Any existing files are backed up to `~/original-dot-files/` before linking so you won't lose anything, though it is up to you to merge the changes if you care.

```zsh
# symlink all the files in this directory
# (excluding init.sh, Brewfile, and zsh directory)
./init.sh
```

There's also a Brewfile with what every Mac gets — shell tools, apps, App Store apps via `mas` — and `roles/dev/Brewfile` on top for the ones that do development. I don't recommend using these without customizing them.

```zsh
brew bundle install
brew bundle install --file roles/dev/Brewfile
```

Everything here is shared across many machines and both operating systems, so tool integrations in `zshrc` are guarded with `command_exists` and only activate where the tool is installed. Machine-specific bits (Homebrew shellenv, extra paths, ssh-add) go in `zsh/zlocal`, which is gitignored and sourced early by `zshrc`.

## git aliases

These short aliases make git really easy to use in your shell:

**Making changes:**
- `a` - `git add`
- `c` - `git commit`
- `chp` - `git cherry-pick`
- `co` - `git checkout`
- `b` - `git branch`
- `m` - `git merge`
- `f` - `git fetch`
- `t` - `git tag`

**Viewing changes:**
- `d` - `git diff` (working tree changes)
- `dc` - `git diff --cached` (staged changes)
- `ds` - `git diff --stat` (summary)
- `s` - `git status -sb` (short status)

**Commit log:**
- `gl` - Fancy graph log with colors and relative dates
- `glo` - `git log --oneline --decorate`

**Stashing:**
- `st` - `git stash`
- `stl` - `git stash list`
- `stp` - `git stash pop`

**Custom scripts:**
See [~/bin](https://github.com/samsonjs/bin) for these ones.
- `rmb` - [`git remove-merged-branches`](https://github.com/samsonjs/bin/blob/main/git-remove-merged-branches) (custom command)
- `gup` - [`git update`](https://github.com/samsonjs/bin/blob/main/git-update) (custom command)

## other aliases

- `be` - Bundle exec
- `doc` - docker-compose
- `u/uu/uuu` - Navigate up 1-3 directories
- `myip` - Get your public IP using icanhazip
