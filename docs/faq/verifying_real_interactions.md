# Recording interactions on real methods

Okay, so imagine this situation: you have a unit test that, among other things,
calls some API that doesn't return a meaningful value and you want to make sure
that you've covered it. Since your test can't observe the result of the call,
you want to make sure it happened

```ruby
def roll_dice(dice)
  @mouth.blow!(dice)
  dice.roll
end
```

If a developer were simultaneously very eager to achieve an extreme amount of
code coverage and also superstitious that _actually_ blowing on the dice is very
important, they could look at that `@mouth.blow!` invocation and ask "how can I
verify that call happened while still calling through to its real
implementation?"

Well, the answer if you're using Mocktail is, "sorry, you can't."

The primary reason this isn't supported is because Mocktail exists to facilitate
test-driven development of code that's fully isolated from its
[dependencies](../support/glossary.md#dependency) in order to design
well-considered interactions, and calling through to a dependency's actual
implementation naturally violates that isolation. Additionally, for any reason a
tester might wish to call through to the actual implementation _other than
superstition_, it stands to reason that at most one of the following is
possible:

1. An integrated test that doesn't use mocks could indirectly observe a
dependency's side effect as evidence that a call occurred and therefore a
mocking library isn't required to [proxy it](../support/glossary.md#proxy), _or_
2. It's not possible for the side effect of the call to be observed by either
the test or its [subject](../support/glossary.md#subject-under-test) and
therefore it's safe to achieve proper isolation by replacing the real
implementation with a fake one

But both conditions can't be true.  As a result, the urge to add a test
assertion that a call occurred in a particular way may represent an [unnecessary
over-specification](https://blog.testdouble.com/posts/2020-02-25-necessary-and-sufficient/).

That said, if you're unswayed and still set on having this functionality, you
can find it in the [rr
gem](https://github.com/rr/rr/blob/master/doc/03_api_overview.md#mockproxy)'s
`mock.proxy` API.

**If you've heard enough, you can go back and consider [non-TDD use cases for Mocktail](../other_uses.md).**

**Or if you're finally ready to walk the golden path, you can revisit [Mocktail as a TDD tool](../tdd.md).**
