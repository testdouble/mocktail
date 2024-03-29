# typed: strict

require_relative "fulfills_stubbing/finds_satisfaction"
require_relative "fulfills_stubbing/describes_unsatisfied_stubbing"

module Mocktail
  class FulfillsStubbing
    extend T::Sig

    sig { void }
    def initialize
      @finds_satisfaction = T.let(FindsSatisfaction.new, Mocktail::FindsSatisfaction)
      @describes_unsatisfied_stubbing = T.let(DescribesUnsatisfiedStubbing.new, Mocktail::DescribesUnsatisfiedStubbing)
    end

    sig { params(dry_call: Call).returns(T.anything) }
    def fulfill(dry_call)
      if (stubbing = satisfaction(dry_call))
        stubbing.satisfied!
        stubbing.effect&.call(dry_call)
      else
        store_unsatisfying_call!(dry_call)
        nil
      end
    end

    sig { params(dry_call: Call).returns(T.nilable(Stubbing[T.anything])) }
    def satisfaction(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?

      @finds_satisfaction.find(dry_call)
    end

    private

    sig { params(dry_call: Call).void }
    def store_unsatisfying_call!(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?

      Mocktail.cabinet.store_unsatisfying_call(
        @describes_unsatisfied_stubbing.describe(dry_call)
      )
    end
  end
end
