# typed: strict

require_relative "../../share/determines_matching_calls"

module Mocktail
  class FindsSatisfaction
    extend T::Sig

    sig { void }
    def initialize
      @determines_matching_calls = T.let(DeterminesMatchingCalls.new, Mocktail::DeterminesMatchingCalls)
    end

    sig { params(dry_call: Call).returns(T.nilable(Stubbing[T.anything])) }
    def find(dry_call)
      Mocktail.cabinet.stubbings.reverse.find { |stubbing|
        demo_config_times = stubbing.demo_config.times

        @determines_matching_calls.determine(dry_call, stubbing.recording, stubbing.demo_config) &&
          (demo_config_times.nil? || demo_config_times > stubbing.satisfaction_count)
      }
    end
  end
end
