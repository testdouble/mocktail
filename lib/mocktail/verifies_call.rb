require_relative "records_demonstration"
require_relative "verifies_call/finds_matching_call"
require_relative "verifies_call/raises_verification_error"

module Mocktail
  class VerifiesCall
    def initialize
      @records_demonstration = RecordsDemonstration.new
      @finds_matching_call = FindsMatchingCall.new
      @raises_verification_error = RaisesVerificationError.new
    end

    def verify(demo, demo_config)
      recording = @records_demonstration.record(demo)
      unless @finds_matching_call.find(recording, demo_config)
        @raises_verification_error.raise(recording, demo_config)
      end
    end
  end
end
