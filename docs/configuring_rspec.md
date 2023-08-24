## Configuring RSpec

If you find yourself in an RSpec establishment, your spec helper just needs
this:

```ruby
RSpec.configure do |config|
  config.include Mocktail::DSL

  config.after(:example) { Mocktail.reset }
end
```

But configuration will only get you so far.  Once your prep is complete, it's
time to roll up your sleeves and get to work.

**Incorporate Mocktail into your [test-driven development workflow](tdd.md).**

**Leverage Mocktail's metaprogramming essence for [other testing utilities](other_uses.md).**
