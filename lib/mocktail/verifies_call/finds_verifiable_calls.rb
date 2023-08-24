require_relative "../share/determines_matching_calls"

module Mocktail
  class FindsVerifiableCalls
    extend T::Sig

    def initialize
      @determines_matching_calls = DeterminesMatchingCalls.new
    end

    def find(recording, demo_config)
      Mocktail.cabinet.calls.select { |call|
        @determines_matching_calls.determine(call, recording, demo_config)
      }
    end
  end
end
