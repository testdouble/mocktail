require_relative "records_demonstration"

module Mocktail
  class RegistersStubbing
    def initialize
      @records_demonstration = RecordsDemonstration.new
    end

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
