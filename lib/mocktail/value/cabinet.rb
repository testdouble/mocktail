module Mocktail
  class Cabinet
    attr_writer :demonstration_in_progress
    attr_reader :calls, :stubbings

    def initialize
      @dry_types = {}
      @doubles = []
      @calls = []
      @stubbings = []
      @demonstration_in_progress = false
    end

    def reset!
      @calls = []
      @stubbings = []
      # Could cause an exception or prevent pollution—you decide!
      @demonstration_in_progress = false
      # note we don't reset dry_types and doubles don't carry any
      # user-meaningful state on them, and clearing them on reset could result
      # in valid mocks being broken and stop working
    end

    def store_double(double)
      @dry_types[double.original_type] ||= double.dry_type
      @doubles << double
    end

    def store_call(call)
      @calls << call
    end

    def store_stubbing(stubbing)
      @stubbings << stubbing
    end

    def dry_type_of(original_type)
      @dry_types[original_type]
    end

    def demonstration_in_progress?
      @demonstration_in_progress
    end
  end
end
