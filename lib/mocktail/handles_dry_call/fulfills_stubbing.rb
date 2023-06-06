# typed: false

require_relative "fulfills_stubbing/finds_satisfaction"
require_relative "fulfills_stubbing/describes_unsatisfied_stubbing"

module Mocktail
  class FulfillsStubbing
    def initialize
      @finds_satisfaction = FindsSatisfaction.new
      @describes_unsatisfied_stubbing = DescribesUnsatisfiedStubbing.new
    end

    def fulfill(dry_call)
      if (stubbing = satisfaction(dry_call))
        stubbing.satisfied!
        stubbing.effect&.call(dry_call)
      else
        store_unsatisfying_call!(dry_call)
        nil
      end
    end

    def satisfaction(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?

      @finds_satisfaction.find(dry_call)
    end

    private

    def store_unsatisfying_call!(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?

      Mocktail.cabinet.store_unsatisfying_call(
        @describes_unsatisfied_stubbing.describe(dry_call)
      )
    end
  end
end
