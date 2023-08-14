# Installing Mocktail

So, you want to get started with Mocktail Classic™, do you? Here's how to get it
installed! (And if you're having second thoughts on passing on [the Sorbet
edition](installation_sorbet.md), there's still time!)

## Installation

First thing's first, add this to your Gemfile:

```ruby
gem "mocktail", group: :test, require: "mocktail"
```

(That redundant `require` option is just a garnish and won't cause any harm; it
may help future readers discern that you're expressly _not_ using
`mocktail/sorbet`.)

Wherever necessary, you can require Mocktail like you would expect:

```ruby
require "mocktail"
```

Next step, it's time to configure Mocktail with your test runner.

**If you're here to keep things classy, maybe [you use Minitest](configuring_minitest.md).**

**If you're about expressing intent as you build your nest, [RSpec works too](configuring_rspec.md).**
