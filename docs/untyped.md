# Getting started with Mocktail

So, you want to get started with Mocktail Classic™, do you? Here's how to get
started.

## Installation

First thing's first, add this to your Gemfile:

```ruby
gem "mocktail", group: :test, require: "mocktail"
```

(That redundant `require` option is just a garnish and won't cause any harm; it
may help future readers discern that you're expressly _not_ using
`mocktail/sorbet`.)

## Configuration

Next, because Mocktail is designed as a test-scoped library, you'll probably
want to configure it with your preferred test runner.

### Minitest

If you're using Minitest, you'll want to plunk this into a test helper:

```ruby
require "mocktail"

class Minitest::Test
  include Mocktail::DSL

  def teardown
    super
    Mocktail.reset
  end
end
```

### RSpec

But if you find yourself in an RSpec establishment, your spec helper just needs
this:

```ruby
require "mocktail"

RSpec.configure do |config|
  config.include Mocktail::DSL

  config.after(:example) { Mocktail.reset }
end
```

But configuration will only get you so far.  Once your prep is complete, it's
time to roll up your sleeves and get to work.

**Incorporate Mocktail into your [test-driven development workflow](tdd.md).**

**Leverage Mocktail's metaprogramming essence for [other testing utilities](other_uses.md).**
