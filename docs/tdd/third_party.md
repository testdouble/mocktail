# Mocking third-party code and gems

A common way people use mocking libraries is to isolate the
[subject](../support/glossary.md#subject-under-test) from third-party code in a
gem. The reason for this is straightforward enough: gems and standard library
classes are often used to broker communication between an application's domain
logic and the outside world via I/O, and one meaningful way to delineate "unit"
and "integration" tests is to establish boundaries like "unit tests don't
interact with the file system, or standard I/O, or the network", then use a
mocking library to enforce that boundary.

Take this example code that writes recipes to a CSV file:

```ruby
Recipe = Struct.new(:name, :ingredients, :instructions, keyword_init: true)

require "csv"

class RecipeWriter
  def write_csv(filename, recipes)
    CSV.open(filename, "w") do |csv|
      csv << ["Name", "Ingredients", "Instructions"]

      recipes.each do |recipe|
        csv << [recipe.name, recipe.ingredients, recipe.instructions]
      end
    end
  end
end
```

Suppose you wanted to take this method and write a unit test afterward that
didn't interact with the file system. You could use a mocking library like
Mocktail to accomplish this.

Because `CSV.open` is a class method, we can pass `CSV` to
[Mocktail.replace](../support/api.md#mocktailreplace) to replace it with a fake:

```ruby
Mocktail.replace(CSV)
subject = RecipeWriter.new
csv = Mocktail.of(CSV)
stubs { CSV.open("some_file.csv", "w") { |blk| blk.call(csv) } }.with { nil }

subject.write_csv("some_file.csv", [
  Recipe.new(
    name: "Mojito",
    ingredients: "mint, lime, rum",
    instructions: "muddle the mint then go nuts"
  ),
  Recipe.new(
    name: "Negroni",
    ingredients: "gin, campari, sweet vermouth",
    instructions: "pour in a glass"
  )
])

verify { csv << ["Name", "Ingredients", "Instructions"] }
verify { csv << ["Mojito", "mint, lime, rum", "muddle the mint then go nuts"] }
verify { csv << ["Negroni", "gin, campari, sweet vermouth", "pour in a glass"] }
```

The above is, indeed, an isolated test of the `write_csv` method, as written.
But, somehow, writing it felt kind of painful!

Let us count the pains:

1. The test is forced to replace a [global class method](class_methods.md)
(`CSV.open`) when an instance would have been simpler and less far-reaching
2. Regardless, we had to create a mock instance of `CSV` anyway, because that's
the type passed to `CSV.open`'s block param. This could confuse readers skimming
the test, since now we've faked `CSV`'s class methods as well as creating a fake
`CSV` instance
3. That fake `CSV` instance gets worse, because the way the subject receives the
value is through a block param, which requires us to invoke the `blk.call(csv)` to pass it in during our stubbing [demonstration](../support/glossary.md#demonstration). This won't
be clear to anyone who isn't familiar with how Mocktail is being used
4. The best assertion we can manage is to verify that the expected calls to
`CSV#<<` occurred, but it means the dependency's contract is limited to a side
effect instead of a return value—which would be easier to debug and compose.
5. Finally, those `verify` calls do nothing to ensure they were called in the
correct order or even inside the `CSV.open` block—both of which are necessary
for the file to be written correctly—indicating a logical gap in the test's
coverage (a custom assertion could be written to validate call-order using
[Mocktail.calls](../support/api.md#mocktailcalls), but it wouldn't be pretty)

That's five pain points we encountered in the writing of a single test of a
pretty simple method!

What could we have done to avoid that pain? Well, because we're mocking a
third-party API (Ruby's standard library [csv](https://github.com/ruby/csv)
gem), all that pain was unavoidable!  If it turns out to be hard to mock out
interactions with third-party code, it's not like we can easily change it to be
easier to work with.

Zooming out, the primary intended benefit of practicing [isolation
testing](../support/glossary.md#isolated-unit-testing) is to improve our code's
design. If we listen to testing pain as we design the interaction between the
subject and its [dependencies](../support/glossary.md#dependency) and respond to
the pain we experience in our tests by changing the API of the _production_
code, it improves that code's usability for everyone, not just a test.
Easier-to-fake code is inherently simpler and therefore easier-to-use code, so
isolated TDD really serves as a useful proxy to put a healthy pressure on
developers to arrive at simple designs.

So, if a core tenet of isolated testing with mocks is to listen to testing pain
as a prompt to improve the design of our subjects' dependencies and we can't
change the design of third-party code when it proves painful, then it stands to
reason we're not getting the most out of the practice of isolated test-driven
development when we mock code we don't own. All we're doing in this case is
subjecting ourselves to unnecessary, useless pain.

So, what can we do instead? One strategy is to introduce a [wrapper
object](../support/glossary.md#wrapper-object) that we _do own_ and use it to
house our dependence on the `csv` gem. Then we can update our code to depend on
the wrapper and once again use [test
doubles](../support/glossary.md#test-double) for their intended purpose: to
improve the design of the wrapper's API.

In this example, that extract refactor might look like this:

```ruby
require "csv"
module Wrap
  class Csv
    def write(filename, header, rows)
      CSV.open(filename, "w") do |csv|
        csv << header
        rows.each do |row|
          csv << row
        end
      end
    end
  end
end

class RecipeWriter
  def initialize
    @csv = Wrap::Csv.new
  end

  def write_csv(filename, recipes)
    @csv.write(
      filename,
      ["Name", "Ingredients", "Instructions"],
      recipes.map { |recipe|
        [recipe.name, recipe.ingredients, recipe.instructions]
      }
    )
  end
end
```

This refactor would result in a much simpler test of `RecipeWriter#write_csv`
if we took a second stab at it:

```ruby
csv = Mocktail.of_next(Wrap::Csv)
subject = RecipeWriter.new

subject.write_csv("some_file.csv", [
  Recipe.new(
    name: "Mojito",
    ingredients: "mint, lime, rum",
    instructions: "muddle the mint then go nuts"
  ),
  Recipe.new(
    name: "Negroni",
    ingredients: "gin, campari, sweet vermouth",
    instructions: "pour in a glass"
  )
])

verify {
  csv.write(
    "some_file.csv",
    ["Name", "Ingredients", "Instructions"],
    [
      ["Mojito", "mint, lime, rum", "muddle the mint then go nuts"],
      ["Negroni", "gin, campari, sweet vermouth", "pour in a glass"]
    ]
  )
}
```

Much more straightforward. It also resolves #1, #2, #3, and #5 on our hit list
of pain points above. The only issue the new factoring doesn't address is the
fact that the `Wrap::Csv#write` has a side effect instead of a return value, but
because our ultimate dependency (`CSV.open`) is effectively a fire-and-forget
method, it's not clear what return value we might want to introduce here without
knowing more about the needs of the caller.

Still, not bad at all. The new class is much more straightforward and its style
more consistent with the rest of our application code that was guided by tests.

## Testing wrapper objects

You might be asking, "but who's testing the wrapper objects", and that's a
question worth asking! In general, if a wrapper is sufficiently simple—meaning,
without logical branching—then it's usually sufficient to rely on your
end-to-end testing to test your wrappers, as they would surely fail if things
didn't work. Testing them on their own in earnest often veers towards [testing
the
framework](https://bignerdranch.com/blog/what-does-dont-test-the-framework-mean/).

## Also, mocking gems doesn't always work

Additionally, Mocktail can't warrant that its methods will work on every class
in every gem out there. If you try to mock a third-party API directly and
something goes wrong, we can't offer support if you open an issue. Instead, we'd
encourage you to try introducing a wrapper as shown above and mock that instead.

## Restarting the first party

Okay, now that we've covered some details on how to mock third-party code, let's
keep up the tempo.

**Head back onto the golden path and use Mocktail to create [fake instances of Ruby classes](./poro.md).**

**Wield your newfound gem-faking wizardry to [stub and verify their methods](../stubbing_and_verifying.md).**

