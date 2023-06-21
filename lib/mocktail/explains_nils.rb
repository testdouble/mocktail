# typed: true

require_relative "share/stringifies_method_name"
require_relative "share/stringifies_call"

module Mocktail
  class ExplainsNils
    def initialize
      @stringifies_method_name = StringifiesMethodName.new
      @stringifies_call = StringifiesCall.new
    end

    def explain
      Mocktail.cabinet.unsatisfying_calls.map { |unsatisfying_call|
        dry_call = unsatisfying_call.call
        other_stubbings = unsatisfying_call.other_stubbings

        UnsatisfyingCallExplanation.new(unsatisfying_call, <<~MSG)
          `nil' was returned by a mocked `#{@stringifies_method_name.stringify(dry_call)}' method
          because none of its configured stubbings were satisfied.

          The actual call:

            #{@stringifies_call.stringify(dry_call, always_parens: true)}

          The call site:

            #{unsatisfying_call.backtrace.first}

          #{@stringifies_call.stringify_multiple(other_stubbings.map(&:recording),
            nonzero_message: "Stubbings configured prior to this call but not satisfied by it",
            zero_message: "No stubbings were configured on this method")}
        MSG
      }
    end
  end
end
