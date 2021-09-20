require_relative "../share/determines_matching_calls"

module Mocktail
  class FindsMatchingCall
    def initialize
      @determines_matching_calls = DeterminesMatchingCalls.new
    end

    def find(recording)
      Mocktail.cabinet.calls.reverse.find { |call|
        @determines_matching_calls.determine(call, recording)
      }
    end
  end
end
