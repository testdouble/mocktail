# Stubbing and verifying mocked methods

The [test doubles](support/glossary.md#test-double) created by Mocktail can be used to aid in the setup and
assertion of [isolated unit tests](support/glossary.md#isolated-unit-testing)
by offering [stub configuration](support/glossary.md#stub) and [spy
verification](support/glossary.md#spy), respectively.

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

  def serve_drink(&taste_test)
    drink = Drink.new
    if taste_test.call(drink)
      drink
    else
      raise BadDrinkError
    end
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

## Stubbing with block parameters

Blocks are a little trickier, because they're always optional and they don't
represent a value that can be compared easily with `==`. Instead, when
configuring a stubbing, the [demonstration](support/glossary.md#demonstration)
invocation can specify a block param which—very weirdly—receives as its only
argument the _actual block_ passed by the subject calling it.

The ability to invoke the block arguments that will be later passed to our
stubbing configuration can allow the test to decide whether a stubbing is
satisfied based on the behavior of the provided block argument.

This is tricky to follow, so let's review the `serve_drink` method we intend to
stub first:

```ruby
def serve_drink(&taste_test)
  drink = Drink.new(sweetness: rand(100))
  if taste_test.call(drink)
    drink
  else
    raise BadDrinkError
  end
end
```

As you can see, if the user's block argument (e.g. `taste_test.call(drink)`)
returns true, then the drink is returned. Otherwise an error is raised.

Now let's imagine a subject that depends on the `Bartop#serve_drink` method and
we want to test it with our mock instance:

```ruby
def order_semi_sweet_drink(bartop)
  bartop.serve_drink do |drink|
    drink.sweetness > 20 && drink.sweetness < 50
  end
end
```

We could test this interaction by testing the boundaries in what we pass the
block:

```ruby
stubs {
  bartop.serve_drink { |blk| blk.call(Drink.new(sweetness: 20)) }
}.with { }
```
