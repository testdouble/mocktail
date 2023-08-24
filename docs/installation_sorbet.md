# Installing Mocktail with Sorbet

Alright, when you add a type checker to isolated unit tests, you're really
cooking with gas. That's because tests that mock out
[dependencies](support/glossary.md#dependency) to design the internal APIs
a [subject](support/glossary.md#subject-under-test) will invoke to divide
its job into smaller, focused sub-tasks is really about defining the _contracts_
between units, and those contracts are most often defined by method signatures:
parameters and return values.

And what are type checkers most concerned with? Oh yeah, parameters and return
values! Instead of potentially brittle tests that may keep passing even when the
contract changes, tests that are strictly type-checked won't lie to you.
Additionally, editors that support [red squiggles and
autocorrections](https://sorbet.org/docs/vscode) for Sorbet can enable
test-driven workflows you won't see elsewhere in Ruby: invoke a method as you
wish it existed in your test, and a quickfix to update the method's definition
is often just a keyboard shortcut away. The power you'll feel is intoxicating!

All that is why topping your Mocktail with Sorbet is a match made in zero-proof
testing heaven. All you need to do to install it is add this to your Gemfile:

```ruby
gem "mocktail", group: :test, require: "mocktail/sorbet"
```

Note the goofy `require: "mocktail/sorbet"` option above. We don't see that a
lot in Ruby, because most gems have a single primary entrypoint to require, and
it's almost always the same name as the gem. However, so that Mocktail can be
used with and without [Sorbet's runtime type
safety](https://sorbet.org/docs/runtime) enabled, it actually ships with two
distributions:

* `require "mocktail"` will load a version of the library that has [effectively
erased](https://github.com/kddnewton/sorbet-eraser) all of its Sorbet types, so
you'll never see a runtime type check
* `require "mocktail/sorbet"` will load the library with all of its Sorbet
signatures intact, so that Sorbet users can benefit from both static and runtime
checks

Be warned: it's all Sorbet or no Sorbet. **Do not cross the streams and require
both of them** unless you like constant redefinition warnings. Mocktail may
throw an error to try to fail fast if it detects both are required, since the
resulting behavior is undefined.

As for Sorbet, that's really all you need to know! Everything else is just the
usual stack of tools like the [srb CLI](https://sorbet.org/docs/cli),
[tapioca](https://github.com/Shopify/tapioca), and
[spoom](https://github.com/Shopify/spoom), plus whatever editor integration you
prefer.

## Type checking your tests

If you want to benefit from type checking in your tests, it means you'll have to
enable type checking in your tests. Code examples you find in the rest of
Mocktail's documentation won't show this, but a test listing might look like
this to get all the benefits that Sorbet-flavored mocktail has to offer
(Minitest below):

```ruby
# typed: strict

require "test_helper"

class StuffDoerTest < Minitest::Test
  extend T::Sig

  sig { params(name: String).void }
  def initialize(name)
    super
    @loads_stuff = T.let(Mocktail.of_next(LoadsStuff), LoadsStuff)

    @subject = T.let(StuffDoer.new, StuffDoer)
  end

  sig { void }
  def test_doing_stuff
    # tests go here
  end
end
```

It probably won't be a surprise to have to add `sig` to each test case when
using `typed: strict`, but the `T.let` in the initializer is a definite bummer.
This could probably be worked around with memoized helpers, but that's outside
the scope of Mocktail for now, especially considering [Sorbet may obviate the
need for explicit declaration of instance variables in the
future](https://sorbet-ruby.slack.com/archives/CHN2L03NH/p1687362667489589?thread_ts=1687357401.417039&cid=CHN2L03NH).

## Configuring your test runner

But before we dive in and start writing tests, we need to configure Mocktail
with your preferred test runner.

**If you were glad to see the code example above was in Minitest, [keep the party going](configuring_minitest.md).**

**If you're annoyed it wasn't in RSpec, [switch trains to go to RSpec-land](configuring_rspec.md).**


