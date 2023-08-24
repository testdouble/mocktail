# Mocking class and module methods

Usually, Mocktail is used to create mock _instances_ of classes and modules, but
you may occassionally want or need to mock out the methods defined on a class or
module.

To fake out all the methods on a type, you can simply pass it to
[Mocktail.replace](/docs/support/api.md#mocktailreplace). Here is a little
example:

```ruby
module Substitution
  def self.for(ingredient)
    ingredient.alternatives.first
  end
end

# Somewhere in a test
Mocktail.replace(Substitution)

stubs { Substitution.for(:peychauds_bitters) }.with { :angosutra_bitters }

Substitution.for(:peychauds_bitters)
=> :angosutra_bitters
```

## Heads up!

`Mocktail.replace` is a spicy operation because it globally mutates that class
or module by overwriting its methods. When called, Mocktail does its best to
dispatch the real or the fake method based on whether the currently-running
thread has faked the type, but this isn't 100% fool-proof, so be wary of
potential pollution if you use [thread-based test
parallelization](https://edgeguides.rubyonrails.org/testing.html#parallel-testing-with-threads),
and remember to configure an after-each hook to call
[Mocktail.reset](/docs/support/api.md#mocktailreset) to restore state.

## Way to stay classy

Where to go from here?

**Head back onto the golden path and use Mocktail to create [fake instances of Ruby classes](./poro.md).**

**Put these overridden classes and modules to good use by [stubbing and verifying their methods](../stubbing_and_verifying.md).**
