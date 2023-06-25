# typed: strict

module Mocktail
  class GathersCallsOfMethod
    extend T::Sig

    def gather(dry_call)
      Mocktail.cabinet.calls.select { |call|
        call.double == dry_call.double &&
          call.method == dry_call.method
      }
    end
  end
end
