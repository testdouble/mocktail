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

## API

The entire public API is listed in the [top-level module's
source](lib/mocktail.rb). Below is a longer menu to explain what goes into each
feature.

### Mocktail.of

`Mocktail.of(module_or_class)` takes a module or class and returns an instance
of an object with fake methods in place of all its instance methods which can
then be stubbed or verified.

```ruby
class Clothes; end;
class Shoe < Clothes
  def tie(laces)
  end
end

shoe = Mocktail.of(Shoe)
shoe.instance_of?(Shoe) # => true
shoe.is_a?(Clothes) # => true
shoe.class == Shoe # => false!
shoe.to_s # => #<Mocktail of Shoe:0x00000001343b57b0>"
```

### Mocktail.of_next

`Mocktail.of_next(klass, [count: 1])` takes a class and returns one mock (the
default) or an array of multiple mocks. It also effectively overrides the
behavior of that class's constructor to return those mock(s) in order and
finally restoring its previous behavior.

For example, if you wanted to test the `Notifier` class below:

```ruby
class Notifier
  def initialize
    @mailer = Mailer.new
  end

  def notify(name)
    @mailer.deliver!("Hello, #{name}")
  end
end
```

You could write a test like this:

```ruby
def test_notifier
  mailer = Mocktail.of_next(Mailer)
  subject = Notifier.new

  subject.notify("Pants")

  verify { mailer.deliver!("Hello, Pants") }
end
```

There's nothing wrong with creating mocks using `Mocktail.of` and passing them
to your subject some other way, but this approach allows you to write very terse
isolation tests without foisting additional indirection or dependency injection
in for your tests' sake.

### Mocktail.stubs

Configuring a fake method to take a certain action or return a particular value
is called "stubbing". To stub a call with a value, you can call `Mocktail.stubs`
(or just `stubs` if you've included `Mocktail::DSL`) and then specify an effect
that will be invoked whenever that call configuration is satisfied using `with`.

The API is very simple in the simple case:

```ruby
class UserRepository
  def find(id, debug: false); end

  def transaction(&blk); end
end
```

You could stub responses to a mock of the `UserRepository` like this:

```ruby
user_repository = Mocktail.of(UserRepository)

stubs { user_repository.find(42) }.with { :a_user }
user_repository.find(42) # => :a_user
user_repository.find(43) # => nil
user_repository.find # => ArgumentError: wrong number of arguments (given 0, expected 1)
```

The block passed to `stubs` is called the "demonstration", because it represents
an example of the kind of calls that Mocktail should match.

If you want to get fancy, you can use matchers to make your demonstration more
dynamic. For example, you could match any number with:

```ruby
stubs { |m| user_repository.find(m.numeric) }.with { :another_user }
user_repository.find(41) # => :another_user
user_repository.find(42) # => :another_user
user_repository.find(43) # => :another_user
```

Stubbings are last-in-wins, which is why the stubbing above would have
overridden the earlier-but-more-specific stubbing of `find(42)`.

A stubbing's effect can also be changed dynamically based on the actual call
that satisfied the demonstration by looking at the `call` block argument:

```ruby
stubs { |m| user_repository.find(m.is_a(Integer)) }.with { |call|
  {id: call.args.first}
}
user_repository.find(41) # => {id: 41}
# Since 42.5 is a Float, the earlier stubbing will win here:
user_repository.find(42.5) # => :another_user
user_repository.find(43) # => {id: 43}
```

It's certainly more complex to think through, but if your stubbed method takes a
block, your demonstration can pass a block of its own and inspect or invoke it:

```ruby
stubs {
  user_repository.transaction { |block| block.call == {id: 41} }
}.with { :successful_transaction }

user_repository.transaction {
  user_repository.find(41)
} # => :successful_transaction
user_repository.transaction {
  user_repository.find(40)
} # => nil
```

There are also several advanced options you can pass to `stubs` to control its
behavior.

`times` will limit the number of times a satisfied stubbing can have its effect:

```ruby
stubs { |m| user_repository.find(m.any) }.with { :not_found }
stubs(times: 2) { |m| user_repository.find(1) }.with { :someone }

user_repository.find(1) # => :someone
user_repository.find(1) # => :someone
user_repository.find(1) # => :not_found
```

`ignore_extra_args` will allow a demonstration to be considered satisfied even
if it fails to specify arguments and keyword arguments made by the actual call:

```ruby
stubs { user_repository.find(4) }.with { :a_person }
user_repository.find(4, debug: true) # => nil

stubs(ignore_extra_args: true) { user_repository.find(4) }.with { :b_person }
user_repository.find(4, debug: true) # => :b_person
```

And `ignore_block` will similarly allow a demonstration to not concern itself
with whether an actual call passed the method a block—it's satisfied either way:

```ruby
stubs { user_repository.transaction }.with { :transaction }
user_repository.transaction {} # => nil

stubs(ignore_block: true) { user_repository.transaction }.with { :transaction }
user_repository.transaction {} # => :transaction
```

### Mocktail.verify

In practice, we've found that we stub far more responses than we explicitly
verify a particular call took place. That's because our code normally returns
some observable value that is _influenced_ by our dependencies' behavior, so
adding additional assertions that they be called would be redundant. That
said, for cases where a dependency doesn't return a value but just has a
necessary side effect, the `verify` method exists (and like `stubs` is included
in `Mocktail::DSL`).

Once you've gotten the hang of stubbing, you'll find that the `verify` method is
intentionally very similar. They almost rhyme.

For this example, consider an `Auditor` class that our code might need to call
to record that certain actions took place.

```ruby
class Auditor
  def record!(message, user_id:, action: nil); end
end
```

Once you've created a mock of the `Auditor`, you can start verifying basic
calls:

```ruby
auditor = Mocktail.of(Auditor)

verify { auditor.record!("hello", user_id: 42) }
# => raised Mocktail::VerificationError
# Expected mocktail of Auditor#record! to be called like:
#
#   record!("hello", user_id: 42)
#
# But it was never called.
```

Wups! Verify will blow up whenever a matching call hasn't occurred, so it
should be called after you've invoked your subject under test along with any
other assertions you have.

If we make a call that satisfies the `verify` call's demonstration, however, you
won't see that error:

```ruby
auditor.record!("hello", user_id: 42)

verify { auditor.record!("hello", user_id: 42) } # => nil
```

There, nothing happened! Just like any other assertion library, you only hear
from `verify` when verification fails.

Just like with `stubs`, you can any built-in or custom matchers can serve as
garnishes for your demonstration:

```ruby
auditor.record!("hello", user_id: 42)

verify { |m| auditor.record!(m.is_a(String), user_id: m.numeric) } # => nil
# But this will raise a VerificationError:
verify { |m| auditor.record!(m.is_a(String), user_id: m.that { |arg| arg > 50}) }
```

When you pass a block to your demonstration, it will be invoked with any block
that was passed to the actual call to the mock. Truthy responses will satisfy
the verification and falsey ones will fail:

```ruby
auditor.record!("ok", user_id: 1) { Time.new }

verify { |m| auditor.record!("ok", user_id: 1) { |block| block.call.is_a?(Time) } } # => nil
# But this will raise a VerificationError:
verify { |m| auditor.record!("ok", user_id: 1) { |block| block.call.is_a?(Date) } }
```

`verify` supports the same options as `stubs`:

* `times` will require the demonstrated call happened exactly `times` times (by
  default, the call has to happen 1 or more times)
* `ignore_extra_args` will allow the demonstration to forego specifying optional
  arguments while still being considered satisfied
* `ignore_block` will similarly allow the demonstration to forego specifying a
  block, even if the actual call receives one

Note that if you want to verify a method _wasn't_ called at all or called a
specific number of times—especially if you don't care about the parameters, you
may want to look at the [Mocktail.calls()](#mocktailcalls) API.

### Mocktail.matchers

You'll probably never need to call `Mocktail.matchers` directly, because it's
the object that is passed to every demonstration block passed to `stubs` and
`verify`. By default, a stubbing (e.g. `stubs { email.send("text") }`) is only
considered satisfied if every argument passed to an actual call was passed an
`==` check. Matchers allow us to relax or change that constraint for both
regular arguments and keyword arguments so that our demonstrations can match
more kinds of method invocations.

Matchers allow you to specify stubbings and verifications that look like this:

```ruby
stubs { |m| email.send(m.is_a(String)) }.with { "I'm an email" }
```

#### Built-in matchers

These matchers come out of the box:

* `any` - Will match any value (even nil) in the given argument position or
  keyword
* `is_a(type)` - Will match when its `type` passes an `is_a?` check against the
  actual argument
* `includes(thing, [**more_things])` - Will match when all of its arguments are
  contained by the corresponding argument—be it a string, array, hash, or
  anything that responds to `includes?`
* `matches(pattern)` - Will match when the provided string or pattern passes
  a `match?` test on the corresponding argument; usually used to match strings
  that contain a particular substring or pattern, but will work with any
  argument that responds to `match?`
* `not(thing)` - Will only match when its argument _does not_ equal (via `!=`)
  the actual argument
* `numeric` - Will match when the actual argument is an instance of `Integer`,
  `Float`, or (if loaded) `BigDecimal`
* `that { |arg| … }` - Takes a block that will receive the actual argument. If
  the block returns truthy, it's considered a match; otherwise, it's not a
  match.

#### Custom matchers

If you want to write your own matchers, check out [the source for
examples](lib/mocktail/matchers/includes.rb). Once you've implemented a class,
just pass it to `Mocktail.register_matcher` in your test helper.

```ruby
class MyAwesomeMatcher < Mocktail::Matchers::Base
  def self.matcher_name
    :awesome
  end

  def match?(actual)
    "#{@expected}✨" == actual
  end
end

Mocktail.register_matcher(MyAwesomeMatcher)
```

Then, a stubbing like this:

```ruby
stubs { |m| user_repository.find(m.awesome(11)) }.with { :awesome_user }

user_repository.find("11")) # => nil
user_repository.find("11✨")) # => :awesome_user
```

### Mocktail.captor

An argument captor is a special kind of matcher… really, it's a matcher factory.
Suppose you have a `verify` call for which one of the expected arguments is
_really_ complicated. Since `verify` tends to be paired with fire-and-forget
APIs that are being invoked for the side effect, this is a pretty common case.
You want to be able to effectively snag that value and then run any number of
specific assertions against it.

That's what `Mocktail.captor` is for. It's easiest to make sense of this by
example. Given this `BigApi` class that's presumably being called by your
subject at the end of a lot of other work building up a payload:

```ruby
class BigApi
  def send(payload); end
end
```

You could capture the value of that payload as part of the verification of the
call:

```ruby
big_api = Mocktail.of(BigApi)

big_api.send({imagine: "that", this: "is", a: "huge", object: "!"})

payload_captor = Mocktail.captor
verify { big_api.send(payload_captor.capture) } # => nil!
```

The `verify` above will pass because _a_ call did happen, but we haven't
asserted anything beyond that yet. What really happened is that
`payload_captor.capture` actually returned a matcher that will return true for
any argument _while also sneakily storing a copy of the argument value_.

That's why we instantiated `payload_captor` with `Mocktail.captor` outside the
demonstration block, so we can inspect its `value` after the `verify` call:

```ruby
payload_captor = Mocktail.captor
verify { big_api.send(payload_captor.capture) } # => nil!

payload = payload_captor.value # {:imagine=>"that", :this=>"is", :a=>"huge", :object=>"!"}
assert_equal "huge", payload[:a]
```

### Mocktail.replace

Mocktail was written to support isolated test-driven development, which usually
results in a lot of boring classes and instance methods. But sometimes you need
to mock singleton methods on classes or modules, and we support that too.

When you call `Mocktail.replace(type)`, all of the singleton methods on the
provided type are replaced with fake methods available for stubbing and
verification. It's really that simple.

For example, if our `Bartender` class has a class method:

```ruby
class Bartender
  def self.cliche_greeting
    ["It's 5 o'clock somewhere!", "Norm!"].sample
  end
end
```

We can replace the behavior of the overall class, and then stub how we'd like it
to respond, in our test:

```ruby
Mocktail.replace(Bartender)
stubs { Bartender.cliche_greeting }.with { "Norm!" }
```

[**Obligatory warning:** Mocktail does its best to ensure that other threads
won't be affected when you replace the singleton methods on a type, but your
mileage may very! Singleton methods are global and code that introspects or
invokes a replaced method in a peculiar-enough way could lead to hard-to-track
down bugs. (If this concerns you, then the fact that class methods are
effectively global state may be a great reason not to rely too heavily on
them!)]

### Mocktail.explain

Test debugging is hard enough when there _aren't_ fake objects flying every
which way, so Mocktail tries to make it a little easier on you. In addition to
returning useful messages throughout the API, the gem also includes an
introspection method `Mocktail.explain(thing)`, which returns a human-readable
`message` and a `reference` object with useful attributes (that vary depending
on the type of fake `thing` you pass in. Below are some things `explain()` can
do.

#### Fake instances created by Mocktail

Any instances created by `Mocktail.of` or `Mocktail.of_next` can be passed to
`Mocktail.explain`, and they will list out all the calls and stubbings made for
each of their fake methods.

Suppose these interactions have occurred:

```ruby
ice_tray = Mocktail.of(IceTray)

Mocktail.stubs { ice_tray.fill(:tap_water, 30) }.with { :some_ice }

ice_tray.fill(:tap_water, 50)
```

You can interrogate what's going on with the fake instance by passing it to
`explain`:

```ruby
explanation = Mocktail.explain(ice_tray)

explanation.reference.type      #=> IceTray
explanation.reference.double    #=> The ice_tray instance
explanation.reference.calls     #=> details on each invocation of each method
explanation.reference.stubbings #=> all stubbings configured for each method
```

Calling `explanation.message` will return:

```
This is a fake `IceTray' instance.

It has these mocked methods:
  - fill

`IceTray#fill' stubbings:

  fill(:tap_water, 30)

`IceTray#fill' calls:

  fill(:tap_water, 50)

```

#### Modules and classes with singleton methods replaced

If you've called `Mocktail.replace()` on a class or module, it can also be
passed to `Mocktail.explain()` for a summary of all the stubbing configurations
and calls made against its faked singleton methods for the currently running
thread.

Imagine a `Shop` class with `self.open!` and `self.close!` singleton methods:

```ruby
Mocktail.replace(Shop)

stubs { |m| Shop.open!(m.numeric) }.with { :a_bar }

Shop.open!(42)

Shop.close!(42)

explanation = Mocktail.explain(Shop)

explanation.reference.type      #=> Shop
explanation.reference.replaced_method_names #=> [:close!, :open!]
explanation.reference.calls     #=> details on each invocation of each method
explanation.reference.stubbings #=> all stubbings configured for each method
```

And `explanation.message` will return:

```ruby
`Shop' is a class that has had its singleton methods faked.

It has these mocked methods:
  - close!
  - open!

`Shop.close!' has no stubbings.

`Shop.close!' calls:

  close!(42)

  close!(42)

`Shop.open!' stubbings:

  open!(numeric)

  open!(numeric)

`Shop.open!' calls:

  open!(42)

  open!(42)
```

#### Methods on faked instances and replaced types

In addition to passing the test double, you can also pass a reference to any
fake method created by Mocktail to `Mocktail.explain`:

```ruby
ice_tray = Mocktail.of(IceTray)

ice_tray.fill(:chilled, 50)

explanation = Mocktail.explain(ice_tray.method(:fill))

explanation.reference.receiver  #=> a reference to the `ice_tray` instance
explanation.reference.calls     #=> details on each invocation of the method
explanation.reference.stubbings #=> all stubbings configured for the method
```

The above may be handy in cases where you want to assert the number of calls of
a method outside the `Mocktail.verify` API:

```ruby
assert_equal 1, explanation.reference.calls.size
```

The explanation will also contain a `message` like this:

```
`IceTray#fill' has no stubbings.

`IceTray#fill' calls:

  fill(:chilled, 50)
```

Replaced singleton methods can also be passed to `explain()`, so something like
`Mocktail.explain(Shop.method(:open!))` from the earlier example would also work
(with `Shop` being the `receiver` on the explanation's `reference`).

#### Undefined methods

There's no API for this one, but Mocktail also offers explanations for methods
that don't exist yet. You'll see this error message whenever you try to call a
method that doesn't exist on a test double. The message is designed to
facilitate "paint-by-numbers" TDD, by including a sample definition of the
method you had attempted to call that can be copy-pasted into a source listing:

```ruby
class IceTray
end

ice_tray = Mocktail.of(IceTray)

ice_tray.fill(:water_type, 30)
# => No method `IceTray#fill' exists for call: (NoMethodError)
#
#      fill(:water_type, 30)
#
#    Need to define the method? Here's a sample definition:
#
#      def fill(water_type, arg)
#      end
```

From there, you can just copy-paste the provided method stub as a starting point
for your new method:

```ruby
class IceTray
  def fill(water_type, amount)
  end
end
```

### Mocktail.explain_nils

Is a faked method returning `nil` and you don't understand why?

By default, methods faked by Mocktail will return `nil` when no stubbing is
satisfied. A frequent frustration, therefore, is when the way `stubs {}.with {}`
is configured does not satisfy a call the way you expected. To try to make
debugging this a little bit easier, the gem provides a top-level
`Mocktail.explain_nils` method that will return an array of summaries of every
call to a faked method that failed to satisfy any stubbings.

For example, suppose you stub this `fill` method like so:

```ruby
ice_tray = Mocktail.of(IceTray)

stubs { ice_tray.fill(:tap_water, 30) }.with { :normal_ice }
```

But then you find that your subject under test is just getting `nil` back and
you don't understand why:

```ruby
def prep
  ice = ice_tray.fill(:tap_water, 50)
  glass.add(ice) # => why is `ice` nil?!
end
```

Whenever you're confused by a nil, you can call `Mocktail.explain_nils` for an
array containing `UnsatisfyingCallExplanation` objects (one for each call to
a faked method that did not satisfy any configured stubbings).

The returned explanation objects will include both a `reference` object to
explore as well a summary `message`:

```ruby
def prep
  ice = ice_tray.fill(:tap_water, 50)
  puts Mocktail.explain_nils.first.message
  glass.add(ice)
end
```

Which will print:

```
This `nil' was returned by a mocked `IceTray#fill' method
because none of its configured stubbings were satisfied.

The actual call:

  fill(:tap_water, 50)

The call site:

  /path/to/your/code.rb:42:in `prep'

Stubbings configured prior to this call but not satisfied by it:

  fill(:tap_water, 30)
```

The `reference` object will have details of the `call` itself, an array of
`other_stubbings` defined on the faked method, and a `backtrace` to determine
which call site produced the unexpected `nil` value.

### Mocktail.calls

When practicing test-driven development, you may want to ensure that a
dependency wasn't called at all. To provide a terse way to express this,
Mocktail offers a top-level `calls(double, method_name = nil)` method that
returns an array of the calls to the mock (optionally filtered to a
particular method name) in the order they were called.

Suppose you were writing a test of this method for example:

```ruby
def import_users
  users_response = @gets_users.get
  if users_response.success?
    @upserts_users.upsert(users_response.data)
  end
end
```

A test case of the negative branch of that `if` statement (when `success?` is
false) might simply want to assert that `@upserts_users.upsert` wasn't called at
all, regardless of its parameters.

The easiest way to do this is to use `Mocktail.calls()` method, which is an
alias of [Mocktail.explain(double).reference.calls](#mocktailexplain) that can
filter to a specific method name. In the case of a test of the above method, you
could assert:

```ruby
# Assert that the `upsert` method on the mock was never called
assert_equal 0, Mocktail.calls(@upserts_users, :upsert).size

# Assert that NO METHODS on the mock were called at all:
assert_equal 0, Mocktail.calls(@upserts_users).size
```

If you're interested in doing more complicated introspection in the nature of
the calls, their ordering, and so forth, the `calls` method will return
`Mocktail::Call` values with the args, kwargs, block, and information about the
original class and method being mocked.

(While this behavior can technically be accomplished with `verify(times: 0) { …
}`, it's verbose and error prone to do so. Because `verify` is careful to only
assert exact argument matches, it can get pretty confusing to remember to tack
on `ignore_extra_args: true` and to call the method with zero args to cover all
cases.)

### Mocktail.reset

This one's simple: you probably want to call `Mocktail.reset` after each test,
but you _definitely_ want to call it if you're using `Mocktail.replace` or
`Mocktail.of_next` anywhere, since those will affect state that is shared across
tests.

Calling reset in a `teardown` or `after(:each)` hook will also improve the
usefulness of messages returned by `Mocktail.explain` and
`Mocktail.explain_nils`.

## Type-safe mocking with Sorbet

You can use Mocktail for type-checked TDD with Sorbet, as Mocktail ships with an
[RBI file](/rbi/mocktail.rbi) that the [tapioca
gems](https://github.com/Shopify/tapioca#generating-rbi-files-for-gems) command
will merge in.

There are some limitations and caveats, however.

* The `count` parameter of `Mocktail.of_next(Class, count:)` will not work, as
  the method signature is intentionally constrained to only returning a single
  mocked instance. Use `Mocktail.of_next_with_count(Class, count:)` instead to
  get an array back with type-checking in place

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
