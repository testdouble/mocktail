## Configuring Minitest

If you're using Minitest, you'll want to plunk this into a test helper:

```ruby
class Minitest::Test
  include Mocktail::DSL

  def teardown
    super
    Mocktail.reset
  end
end
```

Finally, the real (fake) work can begin.

**Incorporate Mocktail into your [test-driven development workflow](tdd.md).**

**Leverage Mocktail's metaprogramming essence for [other testing utilities](other_uses.md).**
