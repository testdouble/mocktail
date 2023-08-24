<img
src="https://user-images.githubusercontent.com/79303/134366631-9c6cfe67-a9c0-4096-bbea-ba1698a85b0b.png"
width="90%"/>

# Mocktail 🍸

Mocktail is a [test
double](https://github.com/testdouble/contributing-tests/wiki/Test-Double)
library for Ruby that provides a terse and robust API for creating mocks,
getting them in the hands of the code you're testing, stub & verify behavior,
and even safely override class methods.

If you'd prefer a voice & video introduction to Mocktail aside from this README,
you might enjoy this ⚡️[Lightning
Talk](https://blog.testdouble.com/talks/2022-05-18-please-mock-me?utm_source=twitter&utm_medium=organic-social&utm_campaign=conf-talk)⚡️
from RailsConf 2022.

## An aperitif

Before getting into the details, let's demonstrate what Mocktail's API looks
like. Suppose you want to test a `Bartender` class:

```ruby
class Bartender
  def initialize
    @shaker = Shaker.new
    @glass = Glass.new
    @bar = Bar.new
  end

  def make_drink(name, customer:)
    if name == :negroni
      drink = @shaker.combine(:gin, :campari, :sweet_vermouth)
      @glass.pour!(drink)
      @bar.pass(@glass, to: customer)
    end
  end
end
```

You could write an isolated unit test with Mocktail like this:

```ruby
shaker = Mocktail.of_next(Shaker)
glass = Mocktail.of_next(Glass)
bar = Mocktail.of_next(Bar)
subject = Bartender.new
stubs { shaker.combine(:gin, :campari, :sweet_vermouth) }.with { :a_drink }
stubs { bar.pass(glass, to: "Eileen") }.with { "🎉" }

result = subject.make_drink(:negroni, customer: "Eileen")

assert_equal "🎉", result
# Oh yeah, and make sure the drink got poured! Silly side effects!
verify { glass.pour!(:a_drink) }
```

## Why Mocktail?

Besides helping you avoid a hangover, Mocktail offers several advantages over
Ruby's other mocking libraries:

* **Simpler test recipes**: [Mocktail.of_next(type)](#mocktailof_next) both
  creates your mock and supplies to your subject under test in a single
  one-liner. No more forcing dependency injection for the sake of your tests
* **WYSIWYG API**: Want to know how to stub a call to `phone.dial(911)`? You
  just demonstrate the call with `stubs { phone.dial(911) }.with { :operator }`.
  Because stubbing & verifying looks just like the actual call, your tests
  becomes a sounding board for your APIs as you invent them
* **Argument validation**: Ever see a test pass after a change to a mocked
  method should have broken it? Not with Mocktail, you haven't
* **Mocked class methods**: Singleton methods on modules and classes can be
  faked out using [`Mocktail.replace(type)`](#mocktailreplace) without
  sacrificing thread safety
* **Super-duper detailed error messages** A good mocking library should make
  coding feel like
  [paint-by-number](https://en.wikipedia.org/wiki/Paint_by_number), thoughtfully
  guiding you from one step to the next. Calling a method that doesn't exist
  will print a sample definition you can copy-paste. Verification failures will
  print every call that _did_ occur. And [Mocktail.explain()](#mocktailexplain)
  provides even more introspection
* **Expressive**: Built-in [argument matchers](#mocktailmatchers) and a simple
  API for adding [custom matchers](#custom-matchers) allow you to tune your
  stubbing configuration and call verification to match _exactly_ what your test
  intends
* **Powerful**: [Argument captors](#mocktailcaptor) for assertions of very
  complex arguments, as well as advanced configuration options for stubbing &
  verification

## Ready to order?

### Install the gem

The main ingredient to add to your Gemfile:

```ruby
gem "mocktail", group: :test
```

### Sprinkle in the DSL

Then, in each of your tests or in a test helper, you'll probably want to include
Mocktail's DSL. (This is optional, however, as every method in the DSL is also
available as a singleton method on `Mocktail`.)

In Minitest, you might add the DSL with:

```ruby
class Minitest::Test
  include Mocktail::DSL
end
```

Or, in RSpec:

```ruby
RSpec.configure do |config|
  config.include Mocktail::DSL
end
```

### Clean up when you're done

To reset Mocktail's internal state between tests and avoid test pollution, you
should also call `Mocktail.reset` after each test:

In Minitest:

```ruby
class Minitest::Test
  # Or, if in a Rails test, in a `teardown do…end` block
  def teardown
    Mocktail.reset
  end
end
```

And RSpec:

```ruby
RSpec.configure do |config|
  config.after(:each) do
    Mocktail.reset
  end
end
```



## Type-safe mocking with Sorbet

You can use Mocktail for type-checked TDD with Sorbet, as Mocktail ships with an
[RBI file](/rbi/mocktail.rbi) that the [tapioca
gems](https://github.com/Shopify/tapioca#generating-rbi-files-for-gems) command
will merge in.

There are some limitations and caveats, however.

* `Mocktail.of(ClassOrModule)` takes a module or a class, but at present Sorbet
  can only type-check classes in this case. For modules, you may need to create
  a test-scoped class that does nothing but include the module and then pass
  _that class_ into `Mocktail.of`
* The `count` parameter of `Mocktail.of_next(Class, count:)` will not work, as
the method signature is intentionally constrained to only returning a single
mocked instance. Use `Mocktail.of_next_with_count(Class, count)` instead to get
an array back with type-checking in place
* Many of Mocktail's built-in matchers need to be approached differently when
type-checking is enabled. Some become less necessary because they serve the role
of constraining types (in the absence of a type system like Sorbet) and for
others because they're so flexible (like `m.includes`) that creating a
sufficiently narrow type signature for their behavior would be impossible.  In
general, even though the matchers' behavior is maximally flexible, each of their
Sorbet signatures has been narrowed to the greatest reasonable extent:
  * [m.any](#many) checks return `T.untyped` [m.includes](#mincludes) is split
  * into several declarations with specialized
  signatures, even though they all share a single implementation:
  * `m.includes(*element)` takes one or more array elements and returns an array
  of that type
  * `m.includes_key(*key)` takes one or more hash keys and returns a hash with
  * that key type `m.includes_hash(*hash)` takes one or more hashes and returns a
  * hash `m.includes_string(*string)` takes one or more substrings and returns a
  string (genericized such that this could be anything that responds to
  `include?`)
  * [m.matches](#mmatches) takes a regex or a substring and returns a string
  * [m.not](#mnot) is genericized to return the type it receives [m.that](#mthat)
  * and [m.numeric](#mnumeric) can't be expressed narrowly
    enough in Sorbet due to its lack of support for generic [type
    deduction](https://sorbet.org/docs/generics#generic-methods)
  * [Mocktail.captor](#mocktailcaptor) (which is implemented as a matcher)
    is also untyped, because there is no way to parameterize the value of
    `captor.capture` by type deduction in Sorbet
  * [Custom matchers](#custom-matchers) are a bit tricky, as the [DSL is
  implemented with `method_missing`](/lib/mocktail/matcher_presentation.rb), so
  you'll probably want to create an RBI file that specifies your matcher's
  signature on `Mocktail::MatcherPresentation`. See this example from this
  repo's [example matcher signature](/sub_projects/sorbet_user/rbi/mocktail.rbi)
  and the `Is5Matcher` in [its test](/sub_projects/sorbet_user/test/sorbet_test.rb)

### I'm seeing a TypeError and it has to do with Sorbet and I don't care about Sorbet

If you're not using Sorbet and you see any type-related errors and you want them to go away,
you can add set the environment variable `SORBET_RUNTIME_DEFAULT_CHECKED_LEVEL=never`.

You can also set this programmatically:

```ruby
require "sorbet-runtime"
T::Configuration.default_checked_level = :never
```

## References

Mocktail is designed following a somewhat academic understanding of what mocking
is and how it should be used. Below are several references on this topic.

Blog Posts and Papers:

- [Endo-Testing: Unit Testing with Mock
  Objects](<https://www2.ccs.neu.edu/research/demeter/related-work/extreme-programming/MockObjectsFinal.PDF>
  by Tim Mackinnon, Steve Freeman, and Philip Craig, the paper that introduced
  mocking presented by the creators of mocking.
- Michael Feathers' [The Flawed Theory Behind Unit
  Testing](<https://michaelfeathers.typepad.com/michael_feathers_blog/2008/06/the-flawed-theo.html>)

Books:

- [_Growing Object-Oriented Software, Guided by
  Tests_](<https://bookshop.org/books/growing-object-oriented-software-guided-by-tests/9780321503626>)
  by Steve Freeman and Nat Price

Talks:

- [Please don’t mock me](https://www.youtube.com/watch?v=Af4M8GMoxi4) by Justin
  Searls

## Acknowledgements

Mocktail is created & maintained by the software agency [Test
Double](https://testdouble.com). If you've ever come across our eponymously-named
[testdouble.js](https://github.com/testdouble/testdouble.js/), you might find
Mocktail's API to be quite similar. The term "test double" was originally coined
by Gerard Meszaros in his book [xUnit Test
Patterns](http://xunitpatterns.com/Test%20Double.html).

The name is inspired by the innovative Java mocking library
[Mockito](https://site.mockito.org). Mocktail also the spiritual successor to
[gimme](https://github.com/searls/gimme), which offers a similar API but which
fell victim to the limitations of Ruby 1.8.7 (and
[@searls](https://twitter.com/searls)'s Ruby chops). Gimme was also one of the
final projects we collaborated with [Jim Weirich](https://github.com/jimweirich)
on, so this approach to isolated unit testing holds a special significance to
us.

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
