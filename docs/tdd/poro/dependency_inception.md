# Dependency _inception_ by magically instantiating mocks with `Mocktail.of_next(SomeClass)`

Perhaps your typical [subject](/docs/support/glossary.md#subject-under-test)
instantiates its own [dependencies](/docs/support/glossary.md#dependency):

```ruby
class ThingHaver
  def initialize
    @thing_1 = Thing1.new
    @thing_2 = Thing2.new
  end
end
```

Or, for the sake of testability, follows a
dependency injection pattern like the following:

```ruby
class ThingHaver
  def initialize(thing_1 = Thing1.new, thing_2 = Thing2.new)
    @thing_1 = thing_1
    @thing_2 = thing_2
  end
end
```

Where, in the universe imagined above, production code always instantiates
`ThingHaver` with no arguments passed to `new` (meaning that `ThingHaver` is
invoking `Thing1.new` and `Thing2.new` itself via default argument assignment),
but unit test code  creates mocks of `Thing1` and `Thing2` and passes them in.
This is a clever pattern, but if our code coverage tools were stricter, we'd see
this actually results in unit tests that fail to cover the execution of each
default assignment, which can lead to surprising bugs if you ever stray from
plain, no-arg constructors.

If either of these cases look familiar, then you may find a lot to like with the
[Mocktail.of_next](/docs/support/api.md#mocktailof_next) convenience function.

Here's the first example and a test listing:

```ruby
class ThingHaver
  def initialize
    @thing_1 = Thing1.new
    @thing_2 = Thing2.new
  end

  def have_things
    [@thing_1, @thing_2].map(&:name)
  end
end

# Elsewhere, in a test:
thing_1 = Mocktail.of_next(Thing1)
thing_2 = Mocktail.of_next(Thing2)
subject = ThingHaver.new
stubs { thing_1.name }.with { :alpha }
stubs { thing_2.name }.with { :omega }

result = subject.have_things

assert_equal [:alpha, :omega], result
```

In the above setup, the value of the `subject`'s `@thing_1` instance variable
will reference the same mock instance as the test's `thing_1` local variable.
The same goes for the subject's `@thing_2` and test's `thing_2`.

Perfectly testable. No goofy dependency injection mechanics necessary.

Here's what is going on under the hood:

1. When passed `Thing1`, `Mocktail.of_next` does two things:
  a. Makes a fake `Thing1` instance and returns it
  b. Overwrites the `Thing1.new` method with an alternate implementation that
     returns the same fake `Thing1` instance
2. The next time `Thing1.new` is called and the fake `Thing1` instance is returned,
Mocktail removes its fake `Thing1.new` method and restores the original, meaning
subsequent calls to `Thing1.new` will once again return real `Thing1` instances

Sneaky!

## Handling dependencies instantiated more than once

Wait, there's more! In the rare event your subject needs multiple instances of
the same dependency at a time (suppose one for each element in an array), you
can generate more than one with [Mocktail.of_next_with_count(type, count)](/docs/support/api.md#mocktailof_next_with_count).

Suppose we rewrite the above example with a single `Thing` class instead of
`Thing1` and `Thing2`. We could use `of_next_with_count` to create both the
fakes in one go, without losing track of the references:

```ruby
class ThingHaver
  def initialize
    @thing_1 = Thing.new
    @thing_2 = Thing.new
  end

  def have_things
    [@thing_1, @thing_2].map(&:name)
  end
end

# Elsewhere, in a test:
thing_1, thing_2 = Mocktail.of_next_with_count(Thing, 2)
subject = ThingHaver.new
stubs { thing_1.name }.with { :alpha }
stubs { thing_2.name }.with { :omega }

result = subject.have_things

assert_equal [:alpha, :omega], result
```

## This doesn't work for modules

If you want Mocktail to create a mock instance from a reference to a module,
however, `Mocktail.of_next` won't work—there's no `new` method for it to
override or for the subject to reference! The best way to do it is either to
create a test-scoped class that includes the module yourself first (and passing
that class to the subject somehow so it can call `new` on it) or to give up on
trying to use `of_next` in favor of
[Mocktail.of](/docs/support/api.md#mocktailof), which can accept a module and
return a mock instance.

## Behold your awesome power!

If your coding style supports it, maximizing `Mocktail.of_next` usage in your
test setup is a great way to mop up redundant test setup boilerplate while
potentially eliminating uncovered dependency instantiations from your production
code.

**Keep the magic flowing by [stubbing and verifying some interactions](../../stubbing_and_verifying.md).**

**Go back and learn of less magical ways to [create mocks](../../tdd.md).**
