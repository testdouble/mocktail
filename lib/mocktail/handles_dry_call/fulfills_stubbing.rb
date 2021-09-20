require_relative "fulfills_stubbing/finds_satisfaction"

module Mocktail
  class FulfillsStubbing
    def initialize
      @finds_satisfaction = FindsSatisfaction.new
    end

    def fulfill(dry_call)
      return if Mocktail.cabinet.demonstration_in_progress?
      if (stubbing = @finds_satisfaction.find(dry_call))
        stubbing.effect&.call(dry_call)
      end
    end
  end
end
