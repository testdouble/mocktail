# typed: false

require_relative "../share/bind"

# The Cabinet stores all thread-local state, so anything that goes here
# is guaranteed by Mocktail to be local to the currently-running thread
module Mocktail
  class Cabinet
    attr_writer :demonstration_in_progress
    attr_reader :calls, :stubbings, :unsatisfying_calls

    def initialize
      @doubles = []
      @calls = []
      @stubbings = []
      @unsatisfying_calls = []
      @demonstration_in_progress = false
    end

    def reset!
      @calls = []
      @stubbings = []
      @unsatisfying_calls = []
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

    def store_unsatisfying_call(unsatisfying_call)
      @unsatisfying_calls << unsatisfying_call
    end

    def demonstration_in_progress?
      @demonstration_in_progress
    end

    def double_for_instance(thing)
      @doubles.find { |double|
        # Intentionally calling directly to avoid an infinite recursion in Bind.call
        Object.instance_method(:==).bind_call(double.dry_instance, thing)
      }
    end

    def stubbings_for_double(double)
      @stubbings.select { |stubbing|
        Bind.call(stubbing.recording.double, :==, double.dry_instance)
      }
    end

    def calls_for_double(double)
      @calls.select { |call|
        Bind.call(call.double, :==, double.dry_instance)
      }
    end
  end
end
