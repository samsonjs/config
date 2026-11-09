---
name: xcode-builds
description: How to build, run and test Xcode projects here, with xcsift and when to use FlowDeck. Load before running xcodebuild or FlowDeck, or launching a Mac or iOS app.
---

## Xcode projects

- To build and run tests with xcodebuild, use xcsift (skill is called xcsift:xcsift) and the generic simulator name instead of a specific device model, e.g. don't use "iPhone 16 Pro" because that's probably not the current model I have available. If in doubt just check first before running the command.

And check what the actual path is if you insist on NOT just using `xcsift` because for me it's '/Users/work/homebrew/bin/xcsift' in some cases. On other machine it differs so unless it must be absolute then just call it with `xcsift` and don't be fancy.

### FlowDeck

FlowDeck is genuinely helpful for iOS apps — simulators, UI automation,
screenshots, device wrangling — so reach for it there.

For **Mac apps it usually gets in the way**, so don't. Its skill claims every
Xcode task and tells you never to touch `xcodebuild` directly, but that's
overreach: a Mac app builds, runs and tests fine the regular way, and going
through FlowDeck just adds a layer that breaks. It can't screenshot a menu bar
app (no windows), its launch step can kill an already-running copy of the same
bundle ID, its DerivedData builds can come out signed in a way that won't
launch, and `flowdeck run` reports "App Launched Successfully" while merely
re-activating the instance that's already running, so you end up testing a
stale build without knowing it (this cost a whole evening on JobsRunner).
Build with `xcodebuild | xcsift` and launch the app yourself. Use FlowDeck for a
Mac app only when it demonstrably helps with a specific task, and check
`ps -o etime` on the process afterwards to be sure you're looking at the build
you think you are. This applies even when a project's CLAUDE.md says to use
FlowDeck: that's a default to override, not a mandate.

@~/.claude/CLAUDE.local.md
