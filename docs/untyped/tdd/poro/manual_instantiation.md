# Manually instantiating mocks

The method we use to instantiate instances of mocks for a given class or module
is [Mocktail.of](/docs/support/api.md#mocktailof).

Assuming you're passing a [dependency](/docs/support/glossary.md#dependency) to
your [subject's](/docs/support/glossary.md#subject-under-test) initializer,
here's an example of how you might do that with `Mocktail.of()`.

Given the following subject:

```ruby
class CashRegister
  def initialize(payment_processor)
    @payment_processor = payment_processor
  end

  def boot!
    @payment_processor.establish_connection
  end
end
```

And this dependency:

```ruby
class PaymentProcessor
  def establish_connection
    # ⚡️ NETWORKING ⚡️
  end
end
```

You could write a little test with Mocktail like this, using
[Mocktail.verify](/docs/support/api.md#mocktailverify) for the assertion:

```ruby
payment_processor = Mocktail.of(PaymentProcessor)
subject = CashRegister.new(payment_processor)

subject.boot!

verify { payment_processor.establish_connection }
```

In the above example, `Mocktail.of(PaymentProcessor)` returns a fake instance
of a `PaymentProcessor` with fake versions of its methods (and retaining their
parameter signatures). Those fake methods will return `nil` by default (unless
stubbed with [Mocktail.stubs](/docs/support/api.md#mocktailstubs)). As shown above,
we can assert that the fake `payment_processor`'s `establish_connection` method
