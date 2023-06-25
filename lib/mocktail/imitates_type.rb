# typed: strict

require_relative "imitates_type/ensures_imitation_support"
require_relative "imitates_type/makes_double"

module Mocktail
  class ImitatesType
    extend T::Sig
    extend T::Generic

    def initialize
      @ensures_imitation_support = EnsuresImitationSupport.new
      @makes_double = MakesDouble.new
    end

    def imitate(type)
      @ensures_imitation_support.ensure(type)
      @makes_double.make(type).tap do |double|
        Mocktail.cabinet.store_double(double)
      end.dry_instance
    end
  end
end
