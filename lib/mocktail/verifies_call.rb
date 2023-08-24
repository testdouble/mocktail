require_relative "records_demonstration"
require_relative "verifies_call/finds_verifiable_calls"
require_relative "verifies_call/raises_verification_error"

module Mocktail
  class VerifiesCall
    extend T::Sig

    def initialize
      @records_demonstration = RecordsDemonstration.new
      @finds_verifiable_calls = FindsVerifiableCalls.new
      @raises_verification_error = RaisesVerificationError.new
    end

    def verify(demo, demo_config)
      recording = @records_demonstration.record(demo, demo_config)
      verifiable_calls = @finds_verifiable_calls.find(recording, demo_config)

      unless verification_satisfied?(verifiable_calls.size, demo_config)
        @raises_verification_error.raise(recording, verifiable_calls, demo_config)
      end
      nil
    end

    private

    def verification_satisfied?(verifiable_call_count, demo_config)
      (demo_config.times.nil? && verifiable_call_count > 0) ||
        (demo_config.times == verifiable_call_count)
    end
  end
end
