# Mocking methods on the subject being tested

Once in a while, it may seem desirable to fake out a method on the [subject
under test](../support/glossary.md#subject-under-test).

The scenario usually looks something like this:

```ruby
class User < ApplicationRecord
  # The method under test:
  def best_promo
    promos = CouponCode.active.flat_map { |coupon_code|
      eligible_promotions(coupon_code)
    }.max_by { |promo|
      promo.percent_discount
    }
  end

  # … 45 other methods

  private

  def eligible_promotions(coupon_code)
    # 30 lines of gnarly queries and conditions
  end
end
```

Suppose a developer wants to  open up `user_spec.rb` and write a spec for
`best_promo`. While `best_promo` might not be the simplest method in the world,
one might imagine a straightforward test with two or three test cases based on
the existence of different `CouponCode` records.

But inevitably, during test setup, it becomes clear that the stuff going on in
`eligible_promotions` is _intense_, and in order to get the database into the
state it would need to be to exercise the logic in `best_promo`, the test would
require fifteen lines of painful and confusing setup code.

This gives rise to the idea: "I could just mock out `eligible_promotions` and
this test would be far clearer and easier to write".

Of course, if that idea led you to this page, I have bad news: Mocktail
can't help you here and it's our opinion that getting into the habit of using
mocking for this purpose is a _really_ bad idea.

Why?

First of all, to mock the `eligible_promotions` method in this case would be an
example of a [partial mock](../support/glossary.md#partial-mock) (discussed
[elsewhere](./partial_mocks.md)). Moreover, that partial mock would be the
_subject itself_—meaning, a test to validate a subject's public API would fake
out the subject's private implementation. As a result, no meaningful confidence
would really be gained from such a test. At best, a test might tell you how the
`best_promo` method would behave in the hypothetical scenario of however
`eligible_promotions` was [stubbed](../support/glossary.md#stubbing), but that
isn't a particularly interesting thing to know (much less codify in a test suite
for perpetuity).

Nevertheless, "mocking the subject" has been remarkably common in Rails
applications since the mid-2000s. In 2010, [DHH
tweeted](https://twitter.com/dhh/status/27444365459?s=20) something that was
seen as controversial with respect to test runners (as RSpec had gained a
massive following) but entirely mundane when it came to mocking libraries
([mocha](https://github.com/freerange/mocha), in this case):

> Q: What testing framework do you use at 37signals? A: test/unit with the occasional splash of mocha. (That's all you need for great testing)

In the experience of the present author, that "splash of mocha" was almost
always used in cases like the above: to fake out one method in an Active Record
model in the service of testing another method in the same model. It made the
initial writing of a test easier, but at the cost of its comprehensibility and
long-term maintainability.

So, if mocking out a method on the subject isn't the solution, what should you
do instead?

In almost every case, this situation is indicating that the subject is serving
too many disparate purposes and the only workable answer is that the method
being tested, the method being mocked, or perhaps _both_ should be extracted
into classes of their own—complete with proper names and a clear
[dependency](../support/glossary.md#dependency) relationship. Only _then_ might
an isolated unit test with mocks be appropriate as a tool to help specify the
terms of that relationship.

To illustrate, we could carry through this refactor by extracting both methods
into new classes and referencing them from the original `best_promo` entrypoint
in the model:

```ruby
class User < ApplicationRecord
  def best_promo
    FindsBestPromo.new.find(CouponCode.active)
  end
end

class FindsBestPromo
  def initialize
    @determines_eligible_promotions = DeterminesEligiblePromotions.new
  end

  def find(coupon_codes)
    coupon_codes.flat_map { |coupon_code|
      @determines_eligible_promotions.determine(coupon_code)
    }.max_by { |promo|
      promo.percent_discount
    }
  end
end

class DeterminesEligiblePromotions
  def determine(coupon_code)
    # 30 lines, still gnarly
  end
end
```

Finally, we could write a test of `FindsBestPromo` that used Mocktail:

```ruby
class FindsBestPromoTest < Minitest::Test
  def setup
    @determines_eligible_promotions = Mocktail.of_next(DeterminesEligiblePromotions)
    @subject = FindsBestPromo.new
  end

  def test_max_discount
    stubs { @determines_eligible_promotions.determine("NEAT25") }.with {
      [
        Promo.new(name: "A", percent_discount: 20),
        Promo.new(name: "B", percent_discount: 25)
      ]
    }
    stubs { @determines_eligible_promotions.determine("COOL15") }.with {
      [Promo.new(name: "C", percent_discount: 15)]
    }

    result = @subject.find(["NEAT25", "COOL15"])

    assert_equal "B", result.name
  end
end
```

Given the starting point, however, it's important to admit that nothing about
this is easy. Extracting behavior from a years-old class that's juggling dozens
of responsibilities where inter-dependencies abound is never as simple as
cut-and-paste. And creating new, single-use classes in a codebase dominated by a
handful of massive files will surely feel out of place and inconsistent.
Finally, deviating from the perceived "Rails Way" requires thoughtful planning,
and is likely to engender conflict without winning the buy-in of all interested
parties. That said, there's no time like the present, because this work willl
only become more difficult with time.

If you've read this far and feel a little hopeless about how to make forward
progress wrangling complexity of this scale, it may make sense to discuss
bringing in outside help, like [the kind we offer at Test
Double](https://testdouble.com/contact).

**If you've heard enough, you can go back and consider [non-TDD use cases for Mocktail](../other_uses.md).**

**Or if you're finally ready to walk the golden path, you can revisit [Mocktail as a TDD tool](../tdd.md).**
