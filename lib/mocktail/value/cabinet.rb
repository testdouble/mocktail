# typed: strict

require_relative "../share/bind"

# The Cabinet stores all thread-local state, so anything that goes here
# is guaranteed by Mocktail to be local to the currently-running thread
module Mocktail
  class Cabinet
    extend T::Sig

    sig { params(demonstration_in_progress: T::Boolean).void }
    attr_writer :demonstration_in_progress

    sig { returns(T::Array[Call]) }
    attr_reader :calls

    sig { returns(T::Array[Stubbing[T.untyped]]) }
    attr_reader :stubbings

    sig { returns(T::Array[UnsatisfyingCall]) }
    attr_reader :unsatisfying_calls

    sig { void }
    def initialize
      @doubles = T.let([], T::Array[Double])
      @calls = T.let([], T::Array[Call])
      @stubbings = T.let([], T::Array[Stubbing[T.untyped]])
      @unsatisfying_calls = T.let([], T::Array[UnsatisfyingCall])
      @demonstration_in_progress = T.let(false, T::Boolean)
    end

    sig { void }
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

    sig { params(double: Double).void }
    def store_double(double)
      @doubles << double
    end

    sig { params(call: Call).void }
    def store_call(call)
      @calls << call
    end

    sig { params(stubbing: Stubbing[T.untyped]).void }
    def store_stubbing(stubbing)
      @stubbings << stubbing
    end

    sig { params(unsatisfying_call: UnsatisfyingCall).void }
    def store_unsatisfying_call(unsatisfying_call)
      @unsatisfying_calls << unsatisfying_call
    end

    sig { returns(T::Boolean) }
    def demonstration_in_progress?
      @demonstration_in_progress
    end

    sig { params(thing: T.untyped).returns(T.nilable(Double)) }
    def double_for_instance(thing)
      @doubles.find { |double|
        # Intentionally calling directly to avoid an infinite recursion in Bind.call
        Object.instance_method(:==).bind_call(double.dry_instance, thing)
      }
    end

    sig { params(double: Double).returns(T::Array[Stubbing[T.untyped]]) }
    def stubbings_for_double(double)
      @stubbings.select { |stubbing|
        Bind.call(stubbing.recording.double, :==, double.dry_instance)
      }
    end

    sig { params(double: Double).returns(T::Array[Call]) }
    def calls_for_double(double)
      @calls.select { |call|
        Bind.call(call.double, :==, double.dry_instance)
      }
    end
  end
end
