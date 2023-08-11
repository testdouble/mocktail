# Mocking class and module methods

Usually, Mocktail is used to create mock _instances_ of classes and modules, but
sometimes you may want or need to mock out the methods on a class or module.

To fake out all the methods on a type, you can simply pass it to
[Mocktail.replace](/docs/support/api.md#mocktailreplace). Here is a little
example:

```ruby
```

## Heads up!

This is a spicier operation than simply creating fake instances because it
globally mutates that class or module for everybody else by overwriting its
methods, so be wary of potential pollution if you use [thread-based test
parallelization](https://edgeguides.rubyonrails.org/testing.html#parallel-testing-with-threads)
and remember to call [Mocktail.reset](/docs/support/api.md#mocktailreset) after
each test!
