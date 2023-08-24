module Mocktail
  module Debug
    extend T::Sig

    # It would be easy and bad for the mocktail lib to call something like
    #
    #   double == other_double
    #
    # But if it's a double, that means anyone who stubs that method could change
    # the internal behavior of the library in unexpected ways (as happened here:
    # https://github.com/testdouble/mocktail/issues/7 )
    #
    # For that reason when we run our tests, we also want to blow up if this
    # happens unintentionally. This works in conjunction with the test
    # MockingMethodfulClassesTest, because it mocks every defined method on the
    # mocked BasicObject

    def self.guard_against_mocktail_accidentally_calling_mocks_if_debugging!
      return unless ENV["MOCKTAIL_DEBUG_ACCIDENTAL_INTERNAL_MOCK_CALLS"]
      raise Mocktail::Error
    rescue Mocktail::Error => e
      base_path = Pathname.new(__FILE__).dirname.to_s
      backtrace_minus_this_and_whoever_called_this = e.backtrace&.[](2..)
      internal_call_sites = backtrace_minus_this_and_whoever_called_this&.take_while { |call_site|
        # the "in `block" is very confusing but necessary to include lines after
        # a stubs { blah.foo }.with { … } call, since that's when most of the
        # good stuff happens
        call_site.start_with?(base_path) || call_site.include?("in `block")
      }&.reject { |call_site| call_site.include?("in `block") } || []

      approved_call_sites = [
        /fulfills_stubbing.rb:(16|20)/,
        /validates_arguments.rb:(18|23)/,
        /validates_arguments.rb:(21|26)/
      ]
      if internal_call_sites.any? && approved_call_sites.none? { |approved_call_site|
        internal_call_sites.first&.match?(approved_call_site)
      }
        raise Error.new <<~MSG
          Unauthorized internal call of a mock internally by Mocktail itself:

          #{internal_call_sites.first}

          Offending call's complete stack trace:

          #{backtrace_minus_this_and_whoever_called_this&.join("\n")}
          ==END OFFENDING TRACE==
        MSG
      end
    end
  end
end
