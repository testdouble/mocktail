module Mocktail
  class StoresMocktails
    def initialize
      @dry_types = {}
      @doubles = []
    end

    def store(double)
      @dry_types[double.original_type] ||= double.dry_type
      @doubles << double
    end

    def dry_type_of(original_type)
      @dry_types[original_type]
    end
  end
end
