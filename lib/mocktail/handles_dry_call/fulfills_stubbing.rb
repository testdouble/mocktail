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
        StubReturnedNil.new(@describes_unsatisfied_stubbing.describe(dry_call))
      end
    end

    def satisfaction(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?
      @finds_satisfaction.find(dry_call)
    end
  end
end
