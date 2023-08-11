# Manually instantiating mocks with `Mocktail.of(SomeClassOrModule)`

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

In the above example, `Mocktail.of(PaymentProcessor)` returns a fake instance of
a `PaymentProcessor`, replete with fake instance methods in place of all its
real ones (and also retaining their parameter signatures). Those fake methods
will return `nil` by default (unless stubbed with
[Mocktail.stubs](/docs/support/api.md#mocktailstubs)). As shown above, we can
assert that the fake `payment_processor`'s `establish_connection` method using
[Mocktail.verify](/docs/support/api.md#mocktailverify).

## Creating mocks of a given module

It's worth noting that `Mocktail.of` will gladly receive a module as an argument
and then create a one-off class only for the purpose of faking it:

``` ruby
module Currency
  def convert(from)
  end
end

currency = Mocktail.of(Currency)
=> #<Mocktail of Currency:0x0000000104a36510>

currency.class
=> #<Class including module for mocktail of Currency:0x00000001077d4620>
```

The above `currency` mock object will have a fake `convert` method on it, just
as an instance of a class including the `Currency` module would.

## You did it!

So there you go, you've got what you need to create mock instances and pass them
to your subjects.

**Delve deeper and explore more about [stubbing and verifying interactions](../../stubbing_and_verifying.md).**

**Go back and consider other ways to [create mocks](../../tdd.md).**
