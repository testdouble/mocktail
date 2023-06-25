# typed: strict

require_relative "records_demonstration"
require_relative "verifies_call/finds_verifiable_calls"
require_relative "verifies_call/raises_verification_error"

module Mocktail
  class VerifiesCall
    extend T::Sig

    sig { void }
    def initialize
      @records_demonstration = T.let(RecordsDemonstration.new, RecordsDemonstration)
      @finds_verifiable_calls = T.let(FindsVerifiableCalls.new, FindsVerifiableCalls)
      @raises_verification_error = T.let(RaisesVerificationError.new, RaisesVerificationError)
    end

    sig { params(demo: T.proc.params(matchers: Mocktail::MatcherPresentation).void, demo_config: DemoConfig).void }
    def verify(demo, demo_config)
      recording = @records_demonstration.record(demo, demo_config)
      verifiable_calls = @finds_verifiable_calls.find(recording, demo_config)

      unless verification_satisfied?(verifiable_calls.size, demo_config)
        @raises_verification_error.raise(recording, verifiable_calls, demo_config)
      end
      nil
    end

    private

    sig { params(verifiable_call_count: Integer, demo_config: DemoConfig).returns(T::Boolean) }
    def verification_satisfied?(verifiable_call_count, demo_config)
      (demo_config.times.nil? && verifiable_call_count > 0) ||
        (demo_config.times == verifiable_call_count)
    end
  end
end
