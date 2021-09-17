module Mocktail
  class MakesDouble
    def initialize
      @cabinet = Mocktail.cabinet
      @declares_dry_class = DeclaresDryClass.new
    end

    def make(klass)
      dry_type = @cabinet.dry_type_of(klass) || @declares_dry_class.declare(klass)
      Double.new(
        original_type: klass,
        dry_type: dry_type,
        dry_instance: dry_type.new
      )
    end
  end
end
