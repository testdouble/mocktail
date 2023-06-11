# Unreleased

* **Breaking change (you probably won't care about)** - When an unknown object
  is passed to `Mocktail.explain`, the returned object's `reference` will now be
  set to a `NoExplanationData` instead of the thing that was passed. To access
  that unknown thing, you can call `NoExplanationData#thing`, (i.e.
  `Mocktail.explain(lol_not_a_mock).reference.thing` and get a reference back to
  `lol_not_a_mock`.)
* **Breaking change (you probably won't care about)** - If you fake a class with
  module that overloads `nil?` you _may_ get an infinite recursion if you
  override it due to an implementation detail in sorbet's `T::Struct` type. See
  [this skipped test](/test/safe/mocking_methodful_classes_test.rb)

# 1.2.2

* As promised in 1.2.1, there were bugs. [#19](https://github.com/testdouble/mocktail/pull/19)

# 1.2.1

* Adds support for faking methods that use options hashes that are called with
  and without curly braces [#17](https://github.com/testdouble/mocktail/pull/17)
  (This is a sweeping change and there will probably be bugs.)

# 1.2.0

* Introduce the Mocktail.calls() API https://github.com/testdouble/mocktail/pull/16

# 1.1.3

* Improve the robustness of how we call the original methods on doubles &
  replaced class methods on mocks internally by Mocktail to avoid behavior being
  altered by how users configure mock objects

# 1.1.2

* Fix cases where classes that redefine built-in methods could cause issues when
  Mocktail in turn called those methods internally
  [#15](https://github.com/testdouble/mocktail/pull/15)

# 1.1.1

* Improve output for undefined singleton methods
  ([#11](https://github.com/testdouble/mocktail/pull/11) by
  [@calebhearth](https://github.com/calebhearth))

# 1.1.0

* Feature: add support for passing methods to `Mocktail.explain()`
* Fix 3.1 support by bypassing highlight_error for custom NoMethodError objects
  raised by Mocktail [error_highlight#20](https://github.com/ruby/error_highlight/issues/20)

# 1.0.0

* First breaking change! 🎉
* Remove support for `Mocktail.explain(nil)` because fake nil values cannot be
made falsey. Pretty big mistake
* Add `Mocktail.explain_nils` which will return explanation objects of every
call that didn't satisfy a stubbing since the last reset, including the call
site where it happened and the backtrace to try to tease out which one you're
looking for

# 0.0.6

* Require pathname, which I missed because `bundle exec` loads it. Wups!

# 0.0.5

* Fix concurrency [#6](https://github.com/testdouble/mocktail/pull/6)

# 0.0.4

* Introduce Mocktail.explain(), which will return a message & reference object
  for any of:
  * A class that has been passed to Mocktail.replace()
  * An instance created by Mocktail.of() or of_next()
  * A nil value returned by an unsatisfied stubbing invocation
* Fix some minor printing issue with the improved NoMethodError released in
  0.0.3


# 0.0.3

* Implement method_missing on all mocked instance methods to print out useful
  information, like the target type, the attempted call, an example method
  definition that would match the call (for paint-by-numbers-like TDD), and
  did_you_mean gem integration of similar method names in case it was just a
  miss
* Cleans artificially-generated argument errors of gem-internal backtraces

# 0.0.2

* Drop Ruby 2.7 support. Unbeknownst to me (since I developed mocktail using
  ruby 3.0), the entire approach to using `define_method` with `*args` and
  `**kwargs` splats only further confuses the [arg
  splitting](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/)
  behavior in Ruby 2.x. So in the event that someone calls a method with an
  ambiguous hash-as-last arg (either in a mock demonstration or call), it will
  be functionally impossible to either (a) validate the args against the
  parameters or (b) compare two calls as being a match for one another. These
  problems could be overcome (by using `eval` instead of `define_method` for
  mocked methods and by expanding the call-matching logic dramatically), but
  who's got the time. Upgrade to 3.0!

# 0.0.1

Initial release
