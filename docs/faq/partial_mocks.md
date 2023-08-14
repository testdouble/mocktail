# Creating partial mocks that fake out a subset of methods

If you've looked at Mocktail's APIs for [creating mock
instances](../support/api.md#mocktailof) and [replacing class or module
methods](../support/api.md#mocktailreplace), you'll find that it's an a bit of
an _all or nothing_ affair.  You can get create an instance of a class with
_all_ its methods replaced with `nil`-returning fakes and you can replace _all_
a module's module methods, but **you can't tell Mocktail to only replace one or a
handful of methods while continuing to call through to some other real methods**.

Why?! Why would we do something so unfair as to withhold such obviously useful
functionality?

Well, the answer—like everything having to do with [test
doubles](../support/glossary.md#test-double)—requires some nuance. In testing
parlance, to replace some of the methods on a
[dependency](../support/glossary.md#dependency) but not all of them is to create
what is called a [partial mock](../support/glossary.md#partial-mock) (click
through its glossary definition for some of the reasons partial mocks are
considered to be an antipattern).

Mocktail was written to promote test-driven development that specifies
thoughtfully-designed classes that interact with other classes, but partial
mocks actually detract from that purpose in practice. As a result Mocktail,
doesn't offer a way to create partial mocks.

If you find yourself wanting to reach for a partial mock, we'd encourage you to
first take it as potential design feedback that a dependency is perhaps too big
and its contract with [subject](../support/glossary.md#subject-under-test) too
porous.

**If you've heard enough, you can go back and consider [non-TDD use cases for Mocktail](../other_uses.md).**

**Or if you're finally ready to walk the golden path, you can revisit [Mocktail as a TDD tool](../tdd.md).**
