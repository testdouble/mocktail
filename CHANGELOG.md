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
