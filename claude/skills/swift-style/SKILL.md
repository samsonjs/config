---
name: swift-style
description: Personal Swift preferences. Load before writing, editing or reviewing Swift or Swift tests.
---

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
