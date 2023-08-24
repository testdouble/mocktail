# Mocking out time

If you want to fake out time in a Ruby test, there are three things to think
about:

1. Editing the actual system time will prevent you from running tests in
parallel, will break HTTPS/SSL certificate authentication, and will generally
wreak havoc on most modern computers

2. Editing the value of when "now" is for `Time` and `Date` in Ruby means that
your Ruby code will have a very different time than your database, any network
dependencies, and any binaries you shell out to

3. _Freezing_ time to a specific, fixed value can open the door to bugs due to
code that comes to depend on that fixedness. For example, two measurements of
"now" equalling one another when that can never be guaranteed to happen in
production

Where does that leave you? I don't know, but Mocktail doesn't do anything to
help you here.

The best tool for this job is definitely the [timecop
gem](https://github.com/travisjeffery/timecop). Just use its `travel` methods to
shift the Ruby-time to where you want, and be mindful that the time will
disagree with any network or system dependencies.

Oh, and if you're looking at the [ActiveSupport time
helpers](https://api.rubyonrails.org/v5.2.4/classes/ActiveSupport/Testing/TimeHelpers.html),
just know that even when they _say_ `travel`, they're actually _freezing_ time,
which creates the category of problems described in issue #3 above.

**If you've heard enough, you can go back and consider [non-TDD use cases for Mocktail](../other_uses.md).**

**Or if you're finally ready to walk the golden path, you can revisit [Mocktail as a TDD tool](../tdd.md).**
