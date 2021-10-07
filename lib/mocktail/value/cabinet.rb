# The Cabinet stores all thread-local state, so anything that goes here
# is guaranteed by Mocktail to be local to the currently-running thread
module Mocktail
  class Cabinet
    attr_writer :demonstration_in_progress
    attr_reader :calls, :stubbings

    def initialize
      @doubles = []
      @calls = []
      @stubbings = []
      @demonstration_in_progress = false
    end

    def reset!
      @calls = []
      @stubbings = []
      # Could cause an exception or prevent pollution—you decide!
      @demonstration_in_progress = false
      # note we don't reset doubles as they don't carry any
      # user-meaningful state on them, and clearing them on reset could result
      # in valid mocks being broken and stop working
    end

    def store_double(double)
      @doubles << double
    end

    def store_call(call)
      @calls << call
    end

    def store_stubbing(stubbing)
      @stubbings << stubbing
    end

    def demonstration_in_progress?
      @demonstration_in_progress
    end

    def double_for_instance(thing)
      @doubles.find { |double| double.dry_instance == thing }
    end

    def stubbings_for_double(double)
      @stubbings.select { |stubbing| stubbing.recording.double == double.dry_instance }
    end

    def calls_for_double(double)
      @calls.select { |call| call.double == double.dry_instance }
    end
  end
end
