# typed: false

require_relative "../../share/determines_matching_calls"

module Mocktail
  class FindsSatisfaction
    def initialize
      @determines_matching_calls = DeterminesMatchingCalls.new
    end

    def find(dry_call)
      Mocktail.cabinet.stubbings.reverse.find { |stubbing|
        @determines_matching_calls.determine(dry_call, stubbing.recording, stubbing.demo_config) &&
          (stubbing.demo_config.times.nil? || stubbing.demo_config.times > stubbing.satisfaction_count)
      }
    end
  end
end
