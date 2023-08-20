# Stubbing and verifying mocked methods

The [test doubles](support/glossary.md#test-double) created by Mocktail can be used to aid in the setup and
assertion of [isolated unit tests](support/glossary.md#isolated-unit-testing)
by offering [stub configuration](support/glossary.md#stub) and [spy
verification](support/glossary.md#spy), respectively.

A headline benefit of choosing Mocktail over other mocking libraries is that
once you know how to stub a method, you also know how to verify a method.
Because Mocktail's [Mocktail.stubs](support/api.md#mocktailstubs) and
[Mocktail.verify](support/api.md#mocktailverify) methods are the two most-used
methods in the library, and because they both enable variations of the same
behavior—`stubs` anticipates future calls to a dependency whereas `verify`
ensures past calls occurred—their APIs are similarly symmetrical. That means
both the `stubs` and `verify` methods share the same basic signature and all the
same options. Mocking is poorly understood by a lot of developers, so we took a
lot of care in designing an API that reflected their conceptual similarity
instead of forcing users to memorize a larger API surface.

## Stubbing behavior

When you've mocked out a [dependency](support/glossary.md#dependency) of the
[subject you're testing](support/glossary.md#subject-under-test), you can use
Mocktail's [stubs](support/api.md#mocktailstubs) DSL method in your tests to
configure its methods to respond based on the arguments and blocks they're
passed.

In these examples, we'll look at an example dependency object with a few
instance methods we might want to stub.

```ruby
class Bartop
  def place_coaster(seat_position = 0)
    # …
  end

  def clean_surface(with:)
    # …
  end
end
```

And we'll work with a mock instance we can create with [Mocktail.of](support/api.md#mocktailof):

```ruby
bartop = Mocktail.of(Bartop)
```

Initially, `bartop` will return `nil` for any invocation of its faked methods,
but will still require arguments match their specified signature, raising
`ArgumentError` if they aren't provided:

```
> bartop.clean_surface(with: :rag)
=> nil
> bartop.clean_surface
=> missing keyword: :with [Mocktail call: `clean_surface'] (ArgumentError)
```

### Simple, no-arg stubbing

Because `place_coaster`'s only parameter has a default value, the simplest
stubbing we can create is the no-arg case:

```ruby
stubs { bartop.place_coaster }.with { :a_coaster }
```

From then onward, calling the method without args will return `:a_coaster`:

```
> bartop.place_coaster
=> :a_coaster
> bartop.place_coaster(1)
=> nil
> bartop.place_coaster()
=> :a_coaster
```

We can also stub the same method multiple times. Newer stubbings will override
older ones, as configured stubbings are matched against invocations on a
"last-in wins" basis:

```ruby
> stubs { bartop.place_coaster }.with { :a_napkin }
=> nil
> bartop.place_coaster
=> :a_napkin
```

You can also limit the number of times a stubbing can be satisfied by providing
a `times` keyword argument to `stubs`:

```ruby
> stubs(times: 2) { bartop.place_coaster }.with { :gold_leaf }
=> nil
> bartop.place_coaster
=> :gold_leaf
> bartop.place_coaster
=> :gold_leaf
> bartop.place_coaster
=> :a_napkin
```

As you can see above, as soon as the `:gold_leaf` stubbing hit its satisfaction
limit of `2`, `place_coaster` started once again responding with `:a_napkin`.

## Stubbing with arguments

Of course, you wouldn't need a library if all you were stubbing was no-arg
methods, so let's start passing some values:

```ruby
stubs { bartop.place_coaster(1) }.with { :coaster_1 }
stubs { bartop.place_coaster(2) }.with { :coaster_2 }
```

And you can probably guess how these will behave:

```ruby
> bartop.place_coaster(2)
=> :coaster_2
> bartop.place_coaster(1)
=> :coaster_1
> bartop.place_coaster(3)
=> nil
```

Keyword arguments work the same way as positional arguments:

```ruby
stubs { bartop.clean_surface(with: :bleach) }.with { "👃" }
stubs { bartop.clean_surface(with: :rag) }.with { "✨" }

> bartop.clean_surface(with: :rag)
=> "✨"
> bartop.clean_surface(with: :bleach)
=> "👃"
> bartop.clean_surface(with: :toothbrush)
=> nil
```

## Stubbing with inexact, dynamic arguments

When fully-isolated, tests will often provide exactly the values that the
subject will receive at every step, and therefore will be able to provide a
demonstration to `stubs` that passes the exact arguments passed by the subject,
or at least expected arguments that will pass an equality check with the actual
ones used by the subject.

But in more complex cases, you may need to configure a stubbing based on a
dynamic description of the arguments. Mocktail enables this with [argument
matchers](support/glossary.md#argument-matcher).

Here's a contrived example of Mocktail's built-in [matcher
API](support/api.md#matching-arguments-dynamically). A subject might pass a
random value to a dependency, which would definitely make it difficult
for a test to know the exact value being passed. Matchers could be used to
configure whether a stubbing or verification is satisfied.

Given this subject:

```ruby
def leave_bathroom
  @wash_hands.for_seconds(rand(5..10))
end
```

A stubbing of `for_seconds` could work around the randomness by just matching
any value using [m.any](support/api.md#many):

```ruby
stubs { |m| @wash_hands.for_seconds(m.any) }.with { :small_suds }

> @wash_hands.for_seconds(3)
=> :small_suds
```

Or it could enforce the type with [m.numeric](support/api.md#mnumeric):

```ruby
stubs { |m| @wash_hands.for_seconds(m.numeric) }.with { :medium_suds }

> @wash_hands.for_seconds(30)
=> :medium_suds
> @wash_hands.for_seconds("some time")
=> nil
```

Or, to be even more precise, a matcher like [m.that](support/api.md#mthat)—which takes a block param
validate the each
argument by itself being invoked

```ruby
stubs { |m|
  @wash_hands.for_seconds(m.that {|s| s.between?(5, 10) })
}.with { :big_suds }

> @wash_hands.for_seconds(7)
=> :big_suds
> @wash_hands.for_seconds(1)
=> nil
> @wash_hands.for_seconds(14)
=> nil
```

For more on the various matchers that ship with Mocktail as well as how to
create your own custom matchers, check out their [API
documentation](support/api.md#matching-arguments-dynamically).

There is a _lot_ more you can do with the
[Mocktail.stubs](support/api.md#mocktailstubs) method, but the basics shown
abouve should cover the vast majority of usage.

## Verifying behavior

As mentioned at the top, Mocktail's mocks work as
[spies](support/glossary.md#spy), allowing users to verify that the
[subject](support/glossary.md#subject) invoked a method as expected. Mocktail
exposes this behavior through its [verify](support/api.md#mocktailverify) DSL
method. This section assumes you read and understand the
[stubs](#stubbing-behavior) section above, as the API is largely the same.

Before we dive in, there's a worthwhile discussion to be had comparing the
merits of using `stubs` and `verify`, because they weren't created equal.

[Pure functions](https://en.wikipedia.org/wiki/Pure_function), those who return
the same value for the same inputs and have no side effects, confer a lot of
benefits to developers: easier to comprehend, easier to compose, and easier to
test. It's generally worth striving to minimize the number of side effects
scattered throughout a codebase, but modern programming languages and frameworks
often make it very easy to write side-effect heavy code by failing to provide
meaningful return values, especially when I/O is concerned. Practicing
test-driven development with mocks, however, shines a bright light on side
effects in your [dependencies](support/glossary.md#dependency): each time you
call `verify`, you're introducing a side effect into your code.

As a result, it's possible (and in a sense, laudable) to only occasionally reach
for Mocktail's `verify` method. That said, Ruby doesn't lend itself especially
well to purely functional designs and, regardless, some number of side effects
are unavoidable for systems that interact with the outside world. And because
side effects are often very difficult to test (given the lack of a return
value), mocking libraries can make it very easy to test an interaction happens
as intended.

Suppose you have a subject that needs to call a dependency that has a side
effect and no return value (be wary of APIs that do both, violating
[command-query separation](support/glossary.md#command-query-separation)).

Let's make up an example of such a dependency:

```ruby
class OrdersLimes
  def order!(lime_count = 1, shipping: :overnight)
    # …
  end
end

orders_limes = Mocktail.of(OrdersLimes)
```

### Verifying a no-arg interaction

The simplest verification a test can make is of a dependent method with no
arguments. We can verify that `order!` was invoked like this:

```ruby
verify { orders_limes.order! }
```

But it hasn't been called yet! So `verify` will raise a
`Mocktail::VerificationError`:

```
Expected mocktail of `OrdersLimes#order!' to be called like: (Mocktail::VerificationError)

  order!

But it was never called.
```

What if we try again? This time calling `order!` first:

```ruby
> orders_limes.order!
=> nil
> verify { orders_limes.order! }
=> nil
```

Nothing happened! Just as you'd expect. The verification passed so no action is
necessary and the test can proceed.

We can call `order!` an arbitrary number of times and verify it as many times as
we like. By default, `verify` only cares that the specified interaction occurred
at least once.

### Verifying methods with arguments

When verifying an invocation with arguments, the same rules apply as for
stubbing: each actual positional and keyword argument is compared with those
specified in the `verify` [demonstration](support/glossary.md#demonstration)
using `==` or, optionally, an [argument
matchers](support/api.md#matching-arguments-dynamically).

Let's call `order!` a few times in different ways:

```ruby
orders_limes.order!(3)
orders_limes.order!(50, shipping: :two_day)
orders_limes.order!(shipping: :ground)
```

Now let's try a verification that we know will fail:

```ruby
verify { orders_limes.order!(4, shipping: :ground) }
```

This will fail as we'd expect, as well as printing out summaries of the prior
invocations:

```ruby
Expected mocktail of `OrdersLimes#order!' to be called like: (Mocktail::VerificationError)

  order!(4, shipping: :ground)

It was called differently 3 times:

  order!(3)

  order!(50, shipping: :two_day)

  order!(shipping: :ground)
```

Mocktail does its best to reconstruct a scrutible string for each invocation to
ease in debugging unexpected failures, but if that's enough, you can also
leverage its [Mocktail.calls](support/api.md#mocktailcalls) method to inspect
each invocation to `order!`, replete with references to each argument passed:

```ruby
> Mocktail.calls(orders_limes, :order!)
=>
[#<Mocktail::Call:0x0000000104631af0
  @args=[3],
  @block=nil,
  @double=#<Mocktail of OrdersLimes:0x00000001044974b0>,
  @dry_type=#<Class for mocktail of OrdersLimes:0x000000010465e758>,
  @kwargs={},
  @method=:order!,
  @original_method=#<UnboundMethod: OrdersLimes#order!(lime_count=..., shipping: ...),
  @original_type=OrdersLimes,
  @singleton=false>,
 #<Mocktail::Call:0x0000000104652318
  @args=[50],
  @block=nil,
  @double=#<Mocktail of OrdersLimes:0x00000001044974b0>,
  @dry_type=#<Class for mocktail of OrdersLimes:0x000000010465e758>,
  @kwargs={:shipping=>:two_day},
  @method=:order!,
  @original_method=#<UnboundMethod: OrdersLimes#order!(lime_count=..., shipping: ...),
  @original_type=OrdersLimes,
  @singleton=false>,
 #<Mocktail::Call:0x00000001046512d8
  @args=[],
  @block=nil,
  @double=#<Mocktail of OrdersLimes:0x00000001044974b0>,
  @dry_type=#<Class for mocktail of OrdersLimes:0x000000010465e758>,
  @kwargs={:shipping=>:ground},
  @method=:order!,
  @original_method=#<UnboundMethod: OrdersLimes#order!(lime_count=..., shipping: ...),
  @original_type=OrdersLimes,
  @singleton=false>]

# Inspecting the most recent call's keyword arguments:
> Mocktail.calls(orders_limes, :order!).last.kwargs
=> {:shipping=>:ground}
```

This is, hopefully, all you'd need to figure out why an expected invocation
failed a `verify` check unexpectedly.

### Verifying a call happened a certain number of times

Just like `stubs`, `verify` has a `times` keyword argument. But, where `stubs`
will limit a stubbing to the number of `times` specified, `verify` will enforce
that exactly that numer of matching invocations took place.

This isn't something you'll need every day, but if you're paranoid about
erroneously making multiple lime orders, then you could ensure it was just
called once:

```ruby
> orders_limes.order!(5, shipping: :two_day)
=> nil
> orders_limes.order!(5, shipping: :two_day)
=> nil
> verify(times: 1) { orders_limes.order!(5, shipping: :two_day) }
```

As you might expect, this will raise a `VerificationError` because the method
was called twice in the specified way instead of once. The error message tries
to make this clear:

```ruby
Expected mocktail of `OrdersLimes#order!' to be called like: (Mocktail::VerificationError)

  order!(5, shipping: :two_day) [1 time]

But it was actually called this way 2 times.
```

### Adding matchers to a verification

Continuing the thread above, let's say you don't know or don't care what the
`shipping:` keyword argument was set to. For the purposes of the test, if that
doesn't matter and you just want to express that only a single order for `5`
limes was made, regardless of shipping method, you can use the
[m.any](support/api.md#many) just like we did in [the stubbing section
above](#stubbing-with-inexact-dynamic-arguments).

To make this point, let's call `order!` one more time with a different shipping
method:

```ruby
> orders_limes.order!(5, shipping: :carrier_pigeon)
=> nil
```

Now we can adjust our `verify` call by using `m.any` for the `shipping` kwarg:

```ruby
verify(times: 1) { |m| orders_limes.order!(5, shipping: m.any) }
```

Because we'd called the method twice in the [immediately
previous](#verifying-a-call-happened-a-certain-number-of-times) and once more
just now. So we should expect Mocktail's error to find all _three_ matching
invocations:

```ruby
Expected mocktail of `OrdersLimes#order!' to be called like: (Mocktail::VerificationError)

  order!(5, shipping: any) [1 time]

But it was actually called this way 3 times.
```

There it is! The expectation sees `shipping: any` and correctly counts that it
was invoked `3 times`.

### Ignoring extraneous arguments entirely

Let's keep pulling the thread and continue the example above.

Suppose this isn't paranoid _enough_ for our tastes. Maybe the method supports
lots of additional optional arguments. And maybe we just _really really_ care
that the method was called once no matter what. We could do this in two ways:

1. Verify that the method was called once, regardless of argument
2. Split the verification in two: verify the call exactly as we expect, and assert
the call count is as we expect

In general, approach #2 is better: it expresses the two intentions separately,
which allows both to be made precisely.

If we'd been expecting `:carrier_pigeon` shipping all along, we could verify it
and then check `Mocktail.calls` to have the right number of invocations on
`:order!`:

```ruby
> verify {  orders_limes.order!(5, shipping: :carrier_pigeon) }
=> nil
> assert_equal 1, Mocktail.calls(orders_limes, :order!).size
=> 💥 asertion failed! Expected 1 but got 3
```

If this is what you're trying to accomplish, this approach is not only more
precise in what it asserts, it expresses the test's intent more clearly to
future readers.

If, however, extraneous arguments are truly irrelevant from the perspective of
the test, approach #1 may be preferable. To enable this, you can pass
`ignore_extra_args: true`.

In our running example, we can omit all or some of the arguments and
`ignore_extra_args` will match every invocation, ignoring the value of their
other arguments. This way, we could specify that we wanted exactly one
invocation of `order!` via carrier pigeon, no matter how many limes were
ordered:

```ruby
> verify(times: 1, ignore_extra_args: true) {  orders_limes.order!(shipping: :carrier_pigeon) }
=> nil
```

For more options and complications, check out the full documentation of the
[verify](support/api.md#mocktailverify) API.

## Pulling it all together

At this point, you've covered either Mocktail's [sorbet
setup](./installation_sorbet.md) or [untyped
install](./installation_untyped.md). You've learned how to instantiate mocks by
[dependency injection](tdd/poro/dependency_injection.md), [dependency
inception](tdd/poro/dependency_inception.md), or [class/module method
replacement](tdd/class_methods.md). And now you've been through the basics of
stubbing and verifying interactions with mocked methods. You've also
probably referenced the full [API documentation](support/api.md) and visited the [glossary of terms](support/glossary.md) a few times.

All that's left is to put it all together and write a test!

**When you're ready, let's [walk through a complete example test](example_test.md), guided by Mocktail.**

