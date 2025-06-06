# sjs's config (dotfiles)

These are my personal *nix config files, hand-crafted since around 2004 when I started by pilfering everything I could find on mailing lists and blogs. They work great on both Linux and macOS, with more server-ish stuff on the Linux side and desktop-ish stuff on the macOS side.

After zsh (big time zsh hipster) this is the first thing I set up in my shell environment on a new machine, along with [~/bin](https://github.com/samsonjs/bin).

## what've we got here?

- **zsh**: custom prompt with git integration, extensive aliases, lots of nitpicky tweaks like subword navigation excluding / for easy subpath traversal
- **$EDITOR**: vim and emacs configs, though the emacs one is fairly dated
- **git**: enhanced diffing, signed commits, pre-commit hooks
- **ruby**: rbenv integration, IRB customizations
- **screen**: yep I'm old, no tmux here
- **iOS simulator stuff**: [device control utilities](https://gist.github.com/insidegui/b570ec998b9e2aeb730f4e142f0593d1) via `devicectl.sh` (from Gui Rambo)

## setup

All files in this repo are symlinked to `~/.filename`. Any existing files are backed up to `~/original-dot-files/` before linking so you won't lose anything, though it is up to you to merge the changes if you care.

```zsh
# symlink all the files in this directory
# (excluding init.sh, Brewfile, and zsh directory)
./init.sh
```

There's also a Brewfile with stuff that I usually want for general shell usability, along with ruby and iOS dev. I don't recommend using this without customizing it.

```zsh
brew bundle install
```

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
- `gls` - `git log --stat`

**Stashing:**
- `st` - `git stash`
- `stl` - `git stash list`
- `stp` - `git stash pop`

**Custom scripts:**
See [~/bin](https://github.com/samsonjs/bin) for these ones.
- `rmb` - `git remove-merged-branches` (custom command)
- `gup` - `git update` (custom command)

## other aliases

- `be` - Bundle exec
- `doc` - docker-compose
- `u/uu/uuu` - Navigate up 1-3 directories
- `myip` - Get your public IP using icanhazip
