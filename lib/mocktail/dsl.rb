module Mocktail
  class RegistersStubbing
    def self.instance
      @self ||= new
    end

    def initialize
      @records_demonstration = RecordsDemonstration.new
    end

    def register(callable)
      cabinet.store_stubbing(Stubbing.new(
        demonstration: callable,
        recording: @recods_demonstration.watch
      ))
    end
  end

  class RecordsDemonstration
    def initialize
      @cabinet = Mocktail.cabinet
    end

    def record(demonstration)
      # pre_demonstration_calls = @cabinet.calls.dup
      demonstration.callable.call
      puts "todo ensure cabinet.calls increased by exactly 1"
      @cabinet.calls.shift
    end
  end

  class Stubbing < Struct.new(
    :demonstration,
    :recording,
    keyword_init: true
  )
  end

  module DSL
    def stub(&demo)
      RegistersStubbing.instance.register(demo)
    end
  end
end
