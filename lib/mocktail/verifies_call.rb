require_relative "records_demonstration"
require_relative "verifies_call/finds_matching_call"
require_relative "verifies_call/raises_verification_error"

module Mocktail
  class VerifiesCall
    def self.instance
      @verifies_call ||= new
    end

    def initialize
      @records_demonstration = RecordsDemonstration.new
      @finds_matching_call = FindsMatchingCall.new
      @raises_verification_error = RaisesVerificationError.new
    end

    def verify(demo)
      recording = @records_demonstration.record(demo)
      unless @finds_matching_call.find(recording)
        @raises_verification_error.raise(recording)
      end
    end
  end
end
