require_relative "../../share/cleans_backtrace"
require_relative "../../share/compares_safely"

module Mocktail
  class DescribesUnsatisfiedStubbing
    def initialize
      @cleans_backtrace = CleansBacktrace.new
      @compares_safely = ComparesSafely.new
    end

    def describe(dry_call)
      UnsatisfyingCall.new(
        call: dry_call,
        other_stubbings: Mocktail.cabinet.stubbings.select { |stubbing|
          @compares_safely.compare(dry_call.double, stubbing.recording.double) &&
            @compares_safely.compare(dry_call.method, stubbing.recording.method)
        },
        backtrace: @cleans_backtrace.clean(Error.new).backtrace
      )
    end
  end
end
