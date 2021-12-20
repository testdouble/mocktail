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
