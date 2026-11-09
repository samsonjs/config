---
name: ruby-style
description: Personal Ruby preferences. Load before writing, editing or reviewing Ruby, RSpec specs, Rakefiles or gemspecs.
---

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
