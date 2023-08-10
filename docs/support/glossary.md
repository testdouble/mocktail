# Glossary of terms

## Dependency

In [isolated unit testing](), a "dependency" almost always refers to a plain ol'
Ruby class for which one or more instances are depended on by a [subject under
test](#subject-under-test).

This usage of the word "dependency" in the context of unit testing with mocking
libraries stands in contrast to most others, where the word most often refers to
third-party libraries and frameworks (usually distributed as Ruby gems) or to
networked services (e.g. an HTTP API). In this use, an integrated application or
project is implied as the thing depending on the dependency.

# Isolated unit testing

Isolated unit testing (also known as "mockist", "London-school" test-driven
development, or discovery testing) was most thoroughly defined in Steve Freeman
and Nat Pryce's book [Growing Object-Oriented Software, Guided by
Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627).
In simplest terms, an isolated unit test exercises the behavior of the
[subject](#subject-under-test) but not of any of its dependencies, instead
replacing all of them at runtime with alternatives controlled by the test. This
puts the subject under extreme isolation, allowing the tester to both:

* Test the subject's behavior without invoking the behavior of its
[dependencies](#dependency) and thereby introducing a transitive dependency on
them
* Assert or observe the subject's behavior directly, as opposed to measuring
the a return value or a side effect of a dependency
* validate the design of the contracts between the subject and its dependencies
by responding to the pain of stubbing and verifying any interactions with the
dependencies, because (assuming an expressive mocking library) API contracts
that are hard to fake are generally also hard to use

## Subject under test

The [subject under test](http://xunitpatterns.com/SUT.html) (or "subject") was
coined by Gerard Meszaros in his book [XUnit
Patterns](https://www.amazon.com/xUnit-Test-Patterns-Refactoring-Code/dp/0131495054/)
to refer to the _thing being tested_. That's all. Nothing too fancy!

In order to promote easier extract refactors, some developers like to assign the
subject under test to a variable name like `@subject` in every test so that test
cases can be moved between file listings with less effort. It has the added
benefit of always clarifying the thing being tested from any other
[dependencies](#dependency) referenced in the test.
