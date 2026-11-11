## Skills with my preferences

Load the matching skill before starting the work it covers, every time:

- `ruby-style`: writing or reviewing Ruby, RSpec, Rakefiles.
- `swift-style`: writing or reviewing Swift.
- `xcode-builds`: building, running or testing anything with Xcode, including FlowDeck.
- `pull-requests`: commit messages, PR bodies, proof, changelogs, pushing and merging.
- `shared-machine`: starting background processes, log captures, simulators or heavy builds.

In Swift, never use `try?` to silence cancellation.

## Canadian Spelling

Use Canadian spelling in all prose that you author — issues, docs, PR/commit text, code comments. Canadian English: `-our` (behaviour, colour), `-re` (centre), doubled consonants (travelled, modelling), but `-ize` like American (organize, initialize).

**How to apply:** Default to Canadian spelling when writing. When editing a doc the user has already touched, never revert their spellings back to American — preserve their edits and only fix remaining American spellings to Canadian. This excludes code in which we do adopt American spelling because most APIs are written that way and I don't want it to be confusing.

## File Organization

- Store all one-off scripts, temporary files, and other generated content that shouldn't be committed in a directory called ~/.claude-scratchpad/ so that it stays completely separate from my code repos and doesn't get committed accidentaly or linted. You can create subdirs in there for each project as you see fit.

## Shared machine

This is my working computer, shared with other sessions. Clean up what you start.

- Give temporary diagnostics a finite runtime and an output limit. Stop your own processes and verify they exited. Never use blanket `pkill` or `killall` by executable name.
- Shut down the simulators you boot and delete the ones you create. Only touch your own, and say which in your final message.
- Ask before artificial stress.

## Shell is zsh, not bash

My shell is zsh, and **zsh does not word-split unquoted parameter expansions**. A loop that looks
like it iterates a list runs exactly once with the whole string as one word:

```zsh
KEEP='alpha beta gamma'
for k in $KEEP; do ...; done   # ONE iteration, k='alpha beta gamma'
for f in $(ls); do ...; done   # same trap with command substitution
J="jj --config x=y"; $J log    # "command not found: jj --config x=y"
```

**How to apply:** don't lean on word splitting. Use a real array (`keep=(alpha beta gamma)`), ask
for splitting explicitly (`${=KEEP}`), or — best when the list is something you're filtering
against — write it to a file and use `grep -f file`. To reuse a command with fixed flags, define a
function (`j() { jj --config x=y "$@"; }`) or an array (`j=(jj --config x=y); $j log`), never a
string variable. The failure is silent: a filter loop quietly
removes nothing and you carry on with a list you believe is already filtered, so verify the count
changed rather than assuming the loop ran. If you genuinely want bash semantics, write a script
with `#!/usr/bin/env bash` and run it with `bash`, don't paste bashisms into the shell.

## Check repo state before editing

Before making fresh edits in a repo, check its VCS state. When the working copy isn't empty — there
are uncommitted changes, or `@` is a described change holding unrelated work — stop and ask how to
proceed rather than piling new edits on top of someone else's half-finished change.

**How to apply:** run `jj status` (or `git status`) before the first edit. Clean, carry on. Not
clean, say what's already sitting there and ask whether to start a fresh change off trunk, squash
into what's there, or work elsewhere. The failure mode is silent: the new work only turns out to be
tangled up with unrelated changes later, when it's time to split it out and push.

Someone else may be mid-edit in that checkout: me, another Claude session, or a subagent. Every jj
command, even a read-only one, snapshots the working copy, so two of us running jj at once can race,
and one party's `jj restore`, `jj new` or `jj abandon` silently wipes the other's uncommitted edits.
"My change won't conflict" is not permission. If the repo isn't clearly idle, use a separate jj
workspace from the first command, or stop and ask.

**Every agent gets its own workspace, never shared.** The main session is an agent too, and so is
each subagent it spawns: one workspace per agent, no exceptions. The main session doesn't edit inside
a subagent's workspace, and no subagent uses the main session's or another subagent's. Follow-up work
on an existing branch goes in a fresh workspace off its bookmark, not in one an agent is still using.
A subagent's brief should tell it to create its own with `jj workspace add`.

## jj (jujutsu VCS)

I use jj. Always check before running write commands with git — when `.jj/` exists, git commands will corrupt the repo state. Existence of a `.git/` directory does not imply that it's NOT a jj repo, it's always colocated in my case and never a plain jj repo. The jujutsu skill (`~/Developer/jujutsu-skill`, canonical at https://git.samhuri.net/sjs/jujutsu-skill with GitHub as a push mirror) carries the full workflow guidance and auto-activates on VCS operations; trust it.

My config sets `revsets.bookmark-advance-to = "(@ ~ empty()) | (@ & empty())-"` for `jj bookmark advance`, so it lands on `@` normally but `@-` when `@` is an empty change.

## Git & GitHub

- Many of my repos have moved from GitHub to my personal Forgejo instance at git.samhuri.net. Check the remote URL before assuming GitHub; for Forgejo repos use `tea` instead of `gh`.
- **Reading diffs**: `GIT_EXTERNAL_DIFF=difft` is exported by my zshrc and inherited by anything launched from a shell, so plain `git diff` hands you difftastic's side-by-side output, which you can't parse or pipe. Use `git pd` (aliased to `diff --no-ext-diff`) whenever you need a real unified patch. Same for jj: pass `--git` to `jj diff`/`jj show`/`jj log -p`. Don't change either default to suit yourself — the colourful output is for me.
- **Never invent rationale.** In code comments, commit messages, PR bodies, issues and design docs, state only reasons I gave or that are verifiable from the code. A plausible guess reads as settled fact once written down, and speculative "why" framing inflates scope — casting a deliberate decision as an oversight invites a redesign nobody asked for. If the why matters and isn't known, ask or leave it out: "deliberately excluded" beats a wrong reason, and "cause unknown" beats naming a suspect.
- My remotes are named `origin` everywhere, on both GitHub and Forgejo, with `upstream` for the project a fork came from. So `git push origin` and remote-tracking bookmarks/branches like `dev@origin` are right by default.
- Never prefix branch or jj bookmark names with my username (e.g. `samhuri/...`). Use just the topic — `fix-foo`, `add-bar`, etc. This applies even if you see existing branches in the repo following the prefix pattern. You can use other prefixes before a slash, just not my name. So `fix/foo` or `chore/blah` or `feature/add-bar` are all perfectly acceptable too.

## Illustrate concepts and flows

When a PR, issue, doc or explanation introduces a concept, a system or subsystem, or a flow that a picture would make easier to follow, include an illustration rather than only text. Do it because it helps the reader, never just to look fancy. Ownership, data flow, state machines, sequences and before/after layouts are typical candidates. A small or self-explanatory change doesn't need one.

**How to apply:** Mermaid is enough in most cases, and GitHub, Forgejo and Linear render it inline. Use a rendered image when Mermaid can't lay the diagram out legibly. Save artifacts for genuinely complicated subjects that need interaction or animation to understand.

## Code Comments

**THIS NOTE ABOUT CODE COMMENTS IS VERY IMPORTANT**

Add code comments sparingly. Focus on why something is done, especially for complex logic, rather than what is done. Only add high-value comments if necessary for clarity or if requested by the user. Do not edit comments that are seperate from the code you are changing. *NEVER* talk to the user or describe your changes through comments. Documentation comments (YARD, Rubydoc, etc.) are excluded from this — those are still expected and good.

## Code Style (General)

- When wrapping long lines of code that are method/function calls, prefer to put all of the parameters on a new line instead of deeply indenting a line with the next parameter on it. e.g. don't do this:
  ```
  Pronto::Analytics::Events.emit_subscription_stripe_start_trial(account_id: account.id,
                                                                 ip:)
  ```
  and instead please do this:
  ```
  Pronto::Analytics::Events.emit_subscription_stripe_start_trial(
    account_id: account.id, ip:,
  )
  ```
  **DO NOT WRAP THEM UNLESS THE LINE IS OVER 100 CHARS WIDE THOUGH. DEFER TO PROJECT-LEVEL MAX LINE LENGTH AS NEEDED IN ANY STYLEGUIDES**

## Development Practices

- **Always follow Test-Driven Development (TDD)**: Write tests first, watch them fail, then implement code to make them pass. This ensures 100% confidence in the implementation.

## Example Data and Test Style

- **Never use the term "user"** - prefer "person", "account", "rider", "shredder", etc.
- Always prefer example.net to example.com
- Make examples fun and inject personality with music and snowboarding or mountain biking references
- For names, alternate between classics like "John Doe <john@example.net>" and "Jane Doe <jane@example.net>" and fun music/sports-inspired names
- Good name examples: Trent Reznor, Fat Mike, El Hefe, Smelly, Greg Graffin or anyone else from 90s punk, industrial, or modern pop music.
- **Keep examples contextually appropriate**: Don't make musicians into athletes! Use actual snowboarders/mountain bikers and don't mix them up.
- Example domains can be creative: trails.example.net, powder.example.net, beats.example.net
- Keep it fun but professional - inject personality without being ridiculous. Don't limit references to what's in this file either. You can use popular movies especially cult classics like Kubrick, Friday, Cohen brothers, Wes Anderson, Guy Ritchie, 90s stuff, etc.
