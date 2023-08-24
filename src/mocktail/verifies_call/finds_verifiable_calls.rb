# typed: strict

require_relative "../share/determines_matching_calls"

module Mocktail
  class FindsVerifiableCalls
    extend T::Sig

    sig { void }
    def initialize
      @determines_matching_calls = T.let(DeterminesMatchingCalls.new, DeterminesMatchingCalls)
    end

    sig { params(recording: Call, demo_config: DemoConfig).returns(T::Array[Call]) }
    def find(recording, demo_config)
      Mocktail.cabinet.calls.select { |call|
        @determines_matching_calls.determine(call, recording, demo_config)
      }
    end
  end
end
