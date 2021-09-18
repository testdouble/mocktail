require_relative "registers_stubbing/records_demonstration"

module Mocktail
  class RegistersStubbing
    def self.instance
      @self ||= new
    end

    def initialize
      @records_demonstration = RecordsDemonstration.new
    end

    def register(demonstration)
      Stubbing.new(
        demonstration: demonstration,
        recording: @records_demonstration.record(demonstration)
      ).tap do |stubbing|
        Mocktail.cabinet.store_stubbing(stubbing)
      end
    end
  end
end
