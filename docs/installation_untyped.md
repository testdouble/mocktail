# Installing Mocktail

So, you want to get started with Mocktail Classic™, do you? Here's how to get it
installed! (And if you're having second thoughts on passing on [the Sorbet
edition](installation_sorbet.md), there's still time!)

## Installation

First thing's first, add this to your Gemfile:

```ruby
gem "mocktail", group: :test, require: "mocktail"
```

(That redundant `require` option is just a garnish and won't cause any harm;
it's there to signal to future readers that you're _not_ using
`mocktail/sorbet`.)

Once installed, you can require Mocktail like you might expect:

```ruby
require "mocktail"
```

Next step: it's time to configure Mocktail with your test runner!

**If you like to keep things classy, maybe [you use Minitest](configuring_minitest.md).**

**Or maybe you'd rather express your intent [to use RSpec](configuring_rspec.md).**
