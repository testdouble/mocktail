# Using mocks to fix a broken test you can't understand

Suppose you have a large suite of tests and one of them just broke the build.
You didn't write this test or the thing it's testing. You just know you've gotta
figure out a way to fix it. The test is sprawling, confusing, and unclear. The
code it's testing isn't much better. You could fight to understand what is going
on, ascertain why things are breaking, and then fix it in a way that left things
better than you found them, but your first impression is that could take you
_days_ to accomplish.

A thought occurs: you could make the test go green by replacing the source of
the error with a mock and then stubbing whatever responses might be necessary
to make the test pass again.

Which is how you wound up installing Mocktail and then clicking through its
silly choose-your-own-adventure README, and here we are.

As discussed elsewhere, Mocktail is designed with [test-driven
development](../tdd.md) of _new_ tests and classes in mind, and not as a tool to
assist in legacy rescue, fixing broken tests, or otherwise coping with existing
complexity.

Situations like the one described above are sadly _very common_, but there is no
alternative to putting in the work to grapple with the complexity and tame it
enough to understand _why_ a test is failing and then ensuring the fix doesn't
undermine the purpose of the test. Put differently, if you were to make the test
pass by plugging a leak in the dike with a mock object, there's no way to know
that the originating failure wasn't indicating an actual real-world bug or
problem in the code. Additionally, the comprehensibility and value of the test
would almost certainly be left worse off after the fix is applied.

Cases like this are one of the reason most experienced developers hate dealing
with mock objects, because they're so often made to paper over underlying
problems by abusing their ability to make the computer lie to you.

As a result, if you have an existing test that wasn't built from the ground-up
as an isolated unit test that used [test
doubles](../support/glossary.md#test-double) to achieve isolation from the
[subject](../support/glossary.md#subject-under-test)'s
[dependencies](../support/glossary.md#dependency), adding mocks to it is almost
always a worse long-term solution than disabling the test entirely.

**If you've heard enough, you can go back and consider [non-TDD use cases for Mocktail](../other_uses.md).**

**Or if you're finally ready to walk the golden path, you can revisit [Mocktail as a TDD tool](../tdd.md).**


