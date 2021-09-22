require_relative "makes_double/declares_dry_class"

module Mocktail
  class MakesDouble
    def initialize
      @declares_dry_class = DeclaresDryClass.new
    end

    def make(klass)
      dry_type = @declares_dry_class.declare(klass)
      Double.new(
        original_type: klass,
        dry_type: dry_type,
        dry_instance: dry_type.new
      )
    end
  end
end
