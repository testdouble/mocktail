# typed: strict

require_relative "records_demonstration"

module Mocktail
  class RegistersStubbing
    extend T::Sig

    sig { void }
    def initialize
      @records_demonstration = T.let(RecordsDemonstration.new, RecordsDemonstration)
    end

    sig {
      type_parameters(:T)
        .params(
          demonstration: T.proc.params(matchers: Mocktail::MatcherPresentation).returns(T.type_parameter(:T)),
          demo_config: DemoConfig
        ).returns(Mocktail::Stubbing[T.type_parameter(:T)])
    }
    def register(demonstration, demo_config)
      Stubbing.new(
        demonstration: demonstration,
        demo_config: demo_config,
        recording: @records_demonstration.record(demonstration, demo_config)
      ).tap do |stubbing|
        Mocktail.cabinet.store_stubbing(stubbing)
      end
    end
  end
end
