# Claude Code Memory

This file helps Claude remember important information about your projects and preferences.

## Canadian Spelling

Use Canadian spelling in all prose that you author — issues, docs, PR/commit text, code comments. Canadian English: `-our` (behaviour, colour), `-re` (centre), doubled consonants (travelled, modelling), but `-ize` like American (organize, initialize).

**How to apply:** Default to Canadian spelling when writing. When editing a doc the user has already touched, never revert their spellings back to American — preserve their edits and only fix remaining American spellings to Canadian. This excludes code in which we do adopt American spelling because most APIs are written that way and I don't want it to be confusing.

## File Organization

- Store all one-off scripts, temporary files, and other generated content that shouldn't be committed in a directory called ~/.claude-scratchpad/ so that it stays completely separate from my code repos and doesn't get committed accidentaly or linted. You can create subdirs in there for each project as you see fit.

## jj (jujutsu VCS)

I use jj. Always check before running write commands with git — when `.jj/` exists, git commands will corrupt the repo state. Existence of a `.git/` directory does not imply that it's NOT a jj repo, it's always colocated in my case and never a plain jj repo. The jujutsu skill (my fork, `~/Developer/jujutsu-skill`) carries the full workflow guidance and auto-activates on VCS operations; trust it.

My config sets `revsets.bookmark-advance-to = "(@ ~ empty()) | (@ & empty())-"` for `jj bookmark advance`, so it lands on `@` normally but `@-` when `@` is an empty change.

## Forgejo & tea

- `tea pr merge --style` accepts every merge style the Forgejo API does, not just the ones its help text lists. In particular `--style fast-forward-only` works for repos that only allow fast-forward merges. Don't fall back to calling the API with curl.

## Git & GitHub

- I prefer jj and am usually using it, so the git advice below mostly applies through jj's git interop (see the jj section above). Only use git directly when the repo genuinely has no `.jj/`.
- Many of my repos have moved from GitHub to my personal Forgejo instance at git.samhuri.net. Check the remote URL before assuming GitHub; for Forgejo repos use `tea` instead of `gh`.
- You should always be able to use `gh` to interact with GitHub.
- When committing files with git, be precise about what gets committed. In a mature codebase, don't commit everything in the working tree without careful consideration. Always check git status and git diff before committing to ensure only the intended changes are included. For newer projects it's probably ok to be looser here.
- **PR descriptions**: two short paragraphs — what was wrong, what it does now. Draft it, then delete every section that isn't one of those two. Write as if telling a coworker in Slack; reading time is the cost, and a small change described at length reads as overcomplicating it.
  - Never restate the diff. No file counts, no "two variable changes", no enumerating what changed, no method names or file-by-file mechanics. The reader opens the diff for *how*.
  - No Testing section, no caveats section, no design-tradeoff section, no hedging. Concerns worth raising — a tradeoff, a related bug, a call someone else should make — go in chat or a review comment, not the body. Don't mention passing tests/specs/linters; that's table stakes and the checks show it.
  - Don't open with an inventory of the old state. One plain sentence covers it.
  - A secondary fix riding along gets one sentence, never a paragraph.
  - Do include evidence I asked for (before/after tables, screenshots) and context the code can't convey: a measurement that motivated the change, a constraint, an interaction with other work.
  - Worst case is after a long investigation — resist compressing it into the body. That belongs in the linked issue.
- **Commit messages and jj change descriptions** can run longer than a PR body, it's a different audience, but the same rule applies about not walking through the diff: what changed and why, plus the one non-obvious gotcha if there is one.
- **Never invent rationale.** In code comments, commit messages, PR bodies, issues and design docs, state only reasons I gave or that are verifiable from the code. A plausible guess reads as settled fact once written down, and speculative "why" framing inflates scope — casting a deliberate decision as an oversight invites a redesign nobody asked for. If the why matters and isn't known, ask or leave it out: "deliberately excluded" beats a wrong reason, and "cause unknown" beats naming a suspect.
- My remotes are named `origin` everywhere, on both GitHub and Forgejo, with `upstream` for the project a fork came from. So `git push origin` and remote-tracking bookmarks/branches like `dev@origin` are right by default.
- When you can use git to reset/revert/checkout to undo changes then prefer that to a bunch of edits. But make sure it's safe before you just blow away changes.
- Never prefix branch or jj bookmark names with my username (e.g. `samhuri/...`). Use just the topic — `fix-foo`, `add-bar`, etc. This applies even if you see existing branches in the repo following the prefix pattern. You can use other prefixes before a slash, just not my name. So `fix/foo` or `chore/blah` or `feature/add-bar` are all perfectly acceptable too.
- Merging PRs: rebase the bookmark onto main locally, push it, then merge with fast-forward only (`tea pr merge --style fast-forward-only <n>`). Never use the server-side rebase merge or "update branch by rebase": both rewrite the commits and strip my SSH signatures. Forgejo repos default to fast-forward-only for this reason; squash is fine when a branch needs flattening, since Forgejo signs squash commits itself. GitHub has no fast-forward merge, so there merge a PR by pushing the rebased branch to main. Merged branches should not linger, but the order matters: merge first, then confirm it landed on the server (the PR reports merged, not just closed, and a fetch shows main at the branch head), and only then delete the branch: `jj bookmark delete <name>` followed by `jj git push --deleted` removes it locally and on the remote in one go, no need for tea or the API. Deleting the branch before the merge is confirmed closes the PR unmerged. Never take "merged" on faith, mine included: check.

## Code Comments

**THIS NOTE ABOUT CODE COMMENTS IS VERY IMPORTANT**

Add code comments sparingly. Focus on why something is done, especially for complex logic, rather than what is done. Only add high-value comments if necessary for clarity or if requested by the user. Do not edit comments that are seperate from the code you are changing. *NEVER* talk to the user or describe your changes through comments. Documentation comments (YARD, Rubydoc, etc.) are excluded from this — those are still expected and good.

## Ruby Style Guide

Don't try to maintain compatibility with older Ruby versions unless absolutely necessary, or supported by the project because it's a library/gem and supports older versions of Ruby. However Ruby 2.x and older are all EOL and unsupported so use all the modern Ruby 3.4+ features unless otherwise instructed.

- Assume Ruby >= 3.4 everywhere — use modern features and syntax freely (`it` block param, `Data.define`, pattern matching, etc.). Don't pin to an exact version; just target 3.4-or-greater all the time.
- If you hit an old macOS system Ruby (e.g. 2.6), that's the wrong interpreter, not a reason to write older code — try `rbenv` (or the project's version manager) to get onto 3.4+ first.
- Use `it` as an implicit single block param for simple cases:
  ```ruby
  things.select { it.answer == 42 }
  ```
- Use Data.define in Ruby instead of hashes in almost all cases, especially with blocks to define methods. And prefer using x? instead of is_x:
  ```ruby
  # Good
  Person = Data.define(:name, :email) do
    def active?
      disabled_at.nil?
    end
  end

  # Avoid
  user = { name: "John", email: "john@example.com" }
  def is_active(user)
    !user[:disabled_at]
  end
  ```
- Multi-line blocks use do/end instead of {curly braces}:
  ```ruby
  # Good
  accounts.each do |account|
    NotificationSender.new.send_notification(to: account)
    account.update_last_seen
  end

  # Avoid
  accounts.each { |account|
    NotificationSender.new.send_notification(to: account)
    account.update_last_seen
  }
  ```
- Prefer using Ruby's named keyword parameters on methods. Similar to modern JavaScript, when named params match the value, then the value can be ommitted:
  ```ruby
  # Good
  def create_account(name:, email:, role: 'general')
    Account.new(name:, email:, role:)
  end

  create_account(name: "John", email: "john@example.com")

  # Avoid passing redundant param values
  def create_account(name:, email:, role: 'general')
    Account.new(name: name, email: email, role: role)
  end

  # Avoid positional params in 99% of cases
  def create_account(name, email, role = 'general')
    Account.new(name, email, role)
  end

  create_account("John", "john@example.com")
  ```
- In RSpec tests, use `before` to create resources that are not referenced in any actual specs, instead of `let!`
- In RSpec, take advantage of defining a subject like `subject { described_class.new(app_data_publisher:) }` at the top and then overriding its dependencies using something like `let(:app_data_publisher)` in specific contexts below that. Dynamic scope is dope.
- Never explicitly stub methods on created objects in RSpec tests. Instead, pass the stubbed values directly when creating the object:
  ```ruby
  # Good - pass stubbed values directly
  let(:subscription) do
    create(:subscription, :ios, :paid, :pro, revenue_amount: 9.99, revenue_currency: 'USD', trial?: false)
  end

  # Avoid - explicit stubbing with allow()
  let(:subscription) { create(:subscription, :ios, :paid, :pro) }
  before do
    allow(subscription).to receive(:revenue_amount).and_return(9.99)
    allow(subscription).to receive(:revenue_currency).and_return('USD')
    allow(subscription).to receive(:trial?).and_return(false)
  end
  ```
- **Line wrapping**: Wrap to minimize rightward drift. When a call runs over the line limit, break right after the opening `(` and put the arguments on their own line at a single level of indent. Don't align continuation lines under the opening parenthesis or under a method in a chain — that drifts far to the right and re-indents everything whenever a name changes length.
```ruby
# Good - break after `(`, arguments on their own line at a single indent
create(
  :poll_response, card_id: card.id, account_id: account.id, poll_title:, ip: '127.0.0.1',
)

# Good - same idea for chained expectations
allow(Pronto::Stripe::StripeCheckoutSessionCreator).to(
  receive(:build).and_return(checkout_session_creator),
)

# Avoid - aligning under the opening parenthesis drifts right
create(:poll_response, card_id: card.id, account_id: account.id, poll_title:,
       ip: '127.0.0.1')

# Avoid - RuboCop's default method-chain alignment drifts even further
allow(Pronto::Stripe::StripeCheckoutSessionCreator).to receive(:build)
                                                               .and_return(checkout_session_creator)
```

## Swift Style Guide

- Mostly using Swift 6 with strict concurrency, Swift testing, and modern features.
- Swift 6 with strict concurrency example:
  ```swift
  actor AccountManager {
    private var accounts: [Account] = []

    func addAccount(_ account: Account) async {
      accounts.append(account)
    }
  }
  ```
- **Never use `try?` to silence cancellation.** `Task.sleep` and other cancellation-aware APIs throw `CancellationError` — swallowing it with `try?` breaks cooperative cancellation. Always use `try` and let the error propagate:
  ```swift
  // Good
  try await Task.sleep(for: .seconds(delay))

  // Bad — silently ignores cancellation
  try? await Task.sleep(for: .seconds(delay))
  ```
- In Swift, lift `let` declarations out of case patterns so there's only one `let` per line:
  ```swift
  // Good
  case let .success(response, data):
  case let .failure(error, response, data):

  // Avoid
  case .success(let response, let data):
  case .failure(let error, let response, let data):
  ```

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

- Before pushing changes, you should most likely run the full test suite and all linting to be sure nothing broke. And always update changelogs when they exist.
- Exception for my Forgejo repos: when a push will trigger CI that runs the same tests and lint, just push and let CI do it. Running them locally, pushing, and then watching CI run them again is redundant — it's all the same machines. Push first, then check the CI result once. This applies to rebases and routine changes; use your judgment and still run things locally when you have a specific reason to (debugging a failure, a change CI doesn't cover, or when I ask).
- **Always follow Test-Driven Development (TDD)**: Write tests first, watch them fail, then implement code to make them pass. This ensures 100% confidence in the implementation.
- When writing changelogs, I don't want to link to keepachangelog.com.
- Add links to github diffs for each version, and put the link after the changes in that same section, e.g.
  > ## [1.2.3] - YYYY-MM-DD
  >
  > ## Added
  > - Something cool
  >
  > [1.2.3]: https://github.com/samsonjs/some-project/compare/1.2.2...1.2.3
  >
  > ## [1.2.2] - YYYY-MM-DD
  >
  > ## Fixed
  > - Something important
  >
  > [1.2.2]: https://github.com/samsonjs/some-project/compare/1.2.1...1.2.2
  (END OF EXAMPLE CHANGELOG)

## Example Data and Test Style

- **Never use the term "user"** - prefer "person", "account", "rider", "shredder", etc.
- Always prefer example.net to example.com
- Make examples fun and inject personality with music and snowboarding or mountain biking references
- For names, alternate between classics like "John Doe <john@example.net>" and "Jane Doe <jane@example.net>" and fun music/sports-inspired names
- Good name examples: Trent Reznor, Fat Mike, El Hefe, Smelly, Greg Graffin or anyone else from 90s punk, industrial, or modern pop music.
- **Keep examples contextually appropriate**: Don't make musicians into athletes! Use actual snowboarders/mountain bikers and don't mix them up.
- Example domains can be creative: trails.example.net, powder.example.net, beats.example.net
- Keep it fun but professional - inject personality without being ridiculous. Don't limit references to what's in this file either. You can use popular movies especially cult classics like Kubrick, Friday, Cohen brothers, Wes Anderson, Guy Ritchie, 90s stuff, etc.

## Xcode projects

- To build and run tests with xcodebuild, use xcsift (skill is called xcsift:xcsift) and the generic simulator name instead of a specific device model, e.g. don't use "iPhone 16 Pro" because that's probably not the current model I have available. If in doubt just check first before running the command.

And check what the actual path is if you insist on NOT just using `xcsift` because for me it's '/Users/work/homebrew/bin/xcsift' in some cases. On other machine it differs so unless it must be absolute then just call it with `xcsift` and don't be fancy.

@~/.claude/CLAUDE.local.md
