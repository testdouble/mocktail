# typed: strict

require_relative "makes_double/declares_dry_class"
require_relative "makes_double/gathers_fakeable_instance_methods"

module Mocktail
  class MakesDouble
    extend T::Sig

    sig { void }
    def initialize
      @declares_dry_class = T.let(DeclaresDryClass.new, DeclaresDryClass)
      @gathers_fakeable_instance_methods = T.let(GathersFakeableInstanceMethods.new, GathersFakeableInstanceMethods)
    end

    sig { params(type: T::Class[Object]).returns(Double) }
    def make(type)
      dry_methods = @gathers_fakeable_instance_methods.gather(type)
      dry_type = @declares_dry_class.declare(type, dry_methods)

      Double.new(
        original_type: type,
        dry_type: dry_type,
        dry_instance: dry_type.new,
        dry_methods: dry_methods
      )
    end
  end
end
