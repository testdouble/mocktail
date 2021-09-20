require_relative "raises_verification_error/gathers_calls_of_method"
require_relative "raises_verification_error/stringifies_call"

module Mocktail
  class VerificationError < Error; end

  class RaisesVerificationError
    def initialize
      @gathers_calls_of_method = GathersCallsOfMethod.new
      @stringifies_call = StringifiesCall.new
    end

    def raise(recording)
      Kernel.raise VerificationError.new <<~MSG
        Expected mocktail of #{recording.original_type.name}##{recording.method} to be called like:

          #{@stringifies_call.stringify(recording)}

        #{describe_other_calls(recording)}
      MSG
    end

    private

    def describe_other_calls(recording)
      calls_of_method = @gathers_calls_of_method.gather(recording)
      if calls_of_method.size == 0
        "But it was never called."
      else
        <<~MSG
          But it was called differently #{calls_of_method.size} time#{"s" if calls_of_method.size > 1}:

          #{calls_of_method.map { |call| "  " + @stringifies_call.stringify(call) }.join("\n\n")}
        MSG
      end
    end
  end
end
