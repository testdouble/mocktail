require_relative "../../share/cleans_backtrace"
require_relative "../../share/bind"

module Mocktail
  class DescribesUnsatisfiedStubbing
    def initialize
      @cleans_backtrace = CleansBacktrace.new
    end

    def describe(dry_call)
      UnsatisfyingCall.new(
        call: dry_call,
        other_stubbings: Mocktail.cabinet.stubbings.select { |stubbing|
          Bind.call(dry_call.double, :==, stubbing.recording.double) &&
            dry_call.method == stubbing.recording.method
        },
        backtrace: @cleans_backtrace.clean(Error.new).backtrace
      )
    end
  end
end
