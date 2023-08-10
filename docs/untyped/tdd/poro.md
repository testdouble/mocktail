# Creating mocked instances of classes you own

Good news! You find yourself on the golden path of Mocktail usage. Creating
mocks of instances of classes that you or your team have authored and can
readily change is right in the crosshairs of what the library was made to do!
(If you're just starting out you should probably target >90% of your Mocktail
usage to be of this variety.)

Exactly _how_ you create these mocked instances depends on how you prefer to
get [dependencies](/docs/support/glossary.md#dependency) into the hands of your
[subject under test](/docs/support/glossary.md#subject-under-test).

**Manually [pass instances of dependencies to your test subject](poro/manual_instantiation.md) (whether directly or through an intermediary dependency injection technique)**

**Allow your subject to [instantiate its dependencies itself](poro/magic_instantiation.md)**
