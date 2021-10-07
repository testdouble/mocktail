module Mocktail
  class DescribesUnsatisfiedStubbing
    def describe(dry_call)
      UnsatisfiedStubbing.new(
        call: dry_call,
        other_stubbings: Mocktail.cabinet.stubbings.select { |stubbing|
                           dry_call.double == stubbing.recording.double &&
                             dry_call.method == stubbing.recording.method
                         }
      )
    end
  end
end
