# Other uses for Mocktail

If you're looking to accomplish something with Mocktail that doesn't involve
test-driven development, let's get real. There's a very high likelihood that
what you're looking to do is either:

1. Not the best tool for the job
2. Not a job worth doing

But hey, could be wrong. The present author once did a [talk about all the ways
people abuse mocking
libraries](https://blog.testdouble.com/talks/2018-03-06-please-dont-mock-me/)
and undermine the value of their tests, so there is a track record of bias here.

By popular demand, here are some ways you might be thinking about using
Mocktail:

**Mocking out the system clock in a vain attempt to [master space and time](faq/mocking_time.md).**

**Mocking an HTTP API by faking out [Ruby's built-in networking](faq/mocking_http.md).**

**Mocking out _just one_ method on an [otherwise real object](faq/partial_mocks.md).**

**Recording method invocations while [calling through to their real implementation](faq/verifying_real_interactions.md).**

**Using Mocktail to fix an existing test that's [failing in a gnarly way you don't understand](faq/existing_tests.md).**

**Mocking out a method on the subject under test, AKA [the thing you're testing itself](faq/mocking_the_subject.md).**

**Or if you've seen enough, you can take a look at [Mocktail as a TDD tool](../tdd.md).**
