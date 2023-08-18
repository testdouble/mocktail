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
csv = Mocktail.of(CSV)
subject = RecipeWriter.new
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

And the above is, indeed, a test of the provided `write_csv` method. But
writing it was kind of painful! Let us count the ways:

1. The test is forced to replace a [global class method](class_methods.md)
(`CSV.open`) when an instance would have been simpler and less far-reaching
2. The fact we had to create a mock instance of `CSV` and then invoke the
block in the course of our stubbing (i.e. the `blk.call(csv)` in `stubs`) won't
be at-all obvious to someone who isn't very familiar with how Mocktail works and
why it's being used here
3. The best assertion we can manage is to verify that the expected calls to
`CSV#<<` occurred, but it means our method's contract is to have a side effect
instead of a return value—which would be easier to debug and compose.
4. Finally, those `verify` calls do nothing to ensure they were called in the
correct order or even inside the `CSV.open` block—both of which are necessary
for the file to be written correctly—indicating a logical gap in the test's
coverage (a custom assertion could be written to validate call-order using
[Mocktail.calls](../support/api.md#mocktailcalls), but it wouldn't be pretty)

That's four pain points we encountered in the writing of a single test of a
pretty simple method!

What could we have done to avoid that pain? Well, because we're mocking a
third-party API (Ruby's standard library [csv](https://github.com/ruby/csv)
gem), all that pain was unavoidable!  When mocking code we don't own, if the API
is awkward or uncomfortable to fake, we can't change its design to make it
easier to work with.

Zooming out, a major purpose of [isolation
testing](../support/glossary.md#isolated-unit-testing) is to listen to testing
pain as we design the interaction between the subject and its
[dependencies](../support/glossary.md#dependency) and respond to pain we
experience in our tests by changing the API of the _production_ code, which
improves its usability for everyone, not just the test. (This rests on the
assumption that easy-to-fake code will also be easy-to-use, which seems to have
proven itself out over the years.)

So, if a core tenet of isolated testing with mocks is to listen to testing pain
as a prompt to improve the design of our subjects' dependencies and we can't
change the design of third-party code when it proves painful, then it stands to
reason we're not getting the most out of the practice of isolated test-driven
development. Instead, we're just subjecting ourselves to unnecessary, useless
pain.

(This is why you might hear the phrase "don't mock what you don't own"
thrown around as an aphorism among people who practice TDD.)

So, what can we do instead? One strategy is to introduce a [wrapper
object](../support/glossary.md#wrapper-object) that we _do own_ and use it to
house our dependence on the `csv` gem. Then, update our code to depend on the
wrapper, and once again use [test doubles](../support/glossary.md#test-double)
for their intended purpose: to influence the design of the wrapper's API.

In this example, that extraction might look like this:

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

Much more straightforward. It also resolves #1, #2, and #4 on our hit list of
pain points above. The only one it doesn't address is the fact that the
dependency has a side effect instead of a return value, but because our ultimate
dependency (`CSV.open`) is effectively a fire-and-forget method, it's not clear
what return value we might want to introduce here without knowing more about the
needs of the caller. Still, not bad at all. The new class is much more
straightforward and its style more consistent with the rest of our application
code that was guided by tests.

(If you're asking, "but who's testing the wrapper objects", that's a question
worth asking. If they're sufficiently simple—meaning, no branching—in most cases
it's sufficient to rely on whatever end-to-end testing you have in place, as it
would surely fail if the wrapper was faulty.)

## Oh, also it doesn't work well

Additionally, Mocktail can't warrant that its methods will work on every class
in every gem out there. If you try to mock a third-party API directly and
something goes wrong, we can't offer support if you open an issue. Instead, we'd
encourage you to try introducing a wrapper as shown above and mock that instead.

## Back to the first-party code

Okay, now that we've covered some details on how to mock third-party code, let's
keep up the tempo.

**Head back onto the golden path and use Mocktail to create [fake instances of Ruby classes](./poro.md).**

**Wield your newfound gem-faking wizardry to [stub and verify their methods](../stubbing_and_verifying.md).**

