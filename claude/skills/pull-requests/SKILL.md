---
name: pull-requests
description: How to write commit messages, PR descriptions and changelogs, what proof a PR carries, and how to push and merge on Forgejo and GitHub. Load before describing a change, opening or updating a PR, pushing, or merging.
---

## Git & GitHub

- I prefer jj and am usually using it, so the git advice below mostly applies through jj's git interop (see the jj section above). Only use git directly when the repo genuinely has no `.jj/`.
- You should always be able to use `gh` to interact with GitHub.
- When committing files with git, be precise about what gets committed. In a mature codebase, don't commit everything in the working tree without careful consideration. Always check git status and git diff before committing to ensure only the intended changes are included. For newer projects it's probably ok to be looser here.
- **PR descriptions**: roughly 2-3 short paragraphs — what was wrong, what it does now, and ideas explored and rejected during development so reviewers don't go down the same rabbit holes. Draft it, then delete every section that isn't one of those two. Write as if telling a coworker in Slack; reading time is the cost, and a small change described at length reads as overcomplicating it.
  - Never restate the diff. No file counts, no "two variable changes", no enumerating what changed, no method names or file-by-file mechanics. The reader opens the diff for *how*.
  - No Testing section, no caveats section, no design-tradeoff section, no hedging. Concerns worth raising — a tradeoff, a related bug, a call someone else should make — go in chat or a review comment, not the body. Don't mention passing tests/specs/linters; that's table stakes and the checks show it.
  - Don't open with an inventory of the old state. One plain sentence covers it.
  - A secondary fix riding along gets one or two sentences at most.
  - Include proof that the change works when it's worthwhile (see "Proof in pull requests" below), and context the code can't convey: a measurement that motivated the change, a constraint, an interaction with other work.
  - Worst case is after a long investigation — resist compressing it into the body. That belongs in the linked issue.
- **Commit messages and jj change descriptions** can run longer than a PR body, it's a different audience, but the same rule applies about not walking through the diff: what changed and why, plus the one non-obvious gotcha if there is one.
- When you can use git to reset/revert/checkout to undo changes then prefer that to a bunch of edits. But make sure it's safe before you just blow away changes.
- Merging PRs: rebase the bookmark onto main locally, push it, then merge with fast-forward only (`tea pr merge --style fast-forward-only <n>`). Never use the server-side rebase merge or "update branch by rebase": both rewrite the commits and strip my SSH signatures. Forgejo repos default to fast-forward-only for this reason; squash is fine when a branch needs flattening, since Forgejo signs squash commits itself. GitHub has no fast-forward merge, so there merge a PR by pushing the rebased branch to main. Merged branches should not linger, but the order matters: merge first, then confirm it landed on the server (the PR reports merged, not just closed, and a fetch shows main at the branch head), and only then delete the branch: `jj bookmark delete <name>` followed by `jj git push --deleted` removes it locally and on the remote in one go, no need for tea or the API. Deleting the branch before the merge is confirmed closes the PR unmerged. Never take "merged" on faith, mine included: check.

## Proof in pull requests

Proof is nice to have, not a requirement. When it's cheap to get and a reviewer would actually find it convincing, include it; when it's awkward, thin or beside the point, skip it and say so rather than stretching for something. It's a judgement call, not a checklist: include what helps a reviewer believe the change, and nothing more. A PR without proof is fine, and so is a draft that has none yet.

- **Tests are the baseline.** The diff includes a test that fails without the change and passes with it, which TDD gives you for free. That's proof living in the diff, not a Testing section: "all tests pass" still doesn't go in the body.
- **Anything you can see gets screenshots or a screen recording.** UI, layout, copy, empty and error states. Show before and after side by side when something changed rather than appeared. Use a recording when the behaviour is a flow, a transition or an animation that a still can't capture. Crop to what matters, and capture from the simulator, device or browser the change targets.
- **Behaviour you can't see gets its output** when that output isn't already in front of the reviewer: a script's trimmed output, a curl response, a before/after table of the numbers. Don't repeat what CI already shows in the checks, like a Terraform plan.
- **Link an artifact when the proof doesn't fit inline**: an interactive comparison, a chart of benchmark runs, a long log annotated down to the lines that matter. Make sure reviewers can actually open the link.
- **Where it goes**: in the body, after the two paragraphs, under a short heading like "Before / after" or "Proof". Embed images and videos inline rather than linking out; on GitHub, use the github-attachment-api skill when drag-and-drop isn't available.
- **Add it when marking the PR ready for review**, not in the initial draft, where it would go stale as the branch changes. A PR that skips the draft stage goes up with its proof already attached, so be very confident in it before doing that.
- **Capture it from the final code.** Re-shoot after the last change rather than reusing a capture from an earlier iteration.
- **Use test accounts and example data.** Nothing personal or real in a screenshot, recording or log.
- **Never contrive proof.** When there's nothing meaningful to show (a pure refactor covered by existing tests, a dependency bump, a docs or config tweak) or no way to capture it, leave it out rather than staging something to fill the slot.

## Forgejo & tea

- `tea pr merge --style` accepts every merge style the Forgejo API does, not just the ones its help text lists. In particular `--style fast-forward-only` works for repos that only allow fast-forward merges. Don't fall back to calling the API with curl.

## Development Practices

- Before pushing changes, you should most likely run the full test suite and all linting to be sure nothing broke.
- Changelogs are for user-facing changes. Update one when a change is user-facing, and leave CI, tooling and other internal work out of it.
- Exception for my Forgejo repos: when a push will trigger CI that runs the same tests and lint, just push and let CI do it. Running them locally, pushing, and then watching CI run them again is redundant — it's all the same machines. Push first, then check the CI result once. This applies to rebases and routine changes; use your judgment and still run things locally when you have a specific reason to (debugging a failure, a change CI doesn't cover, or when I ask).
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
