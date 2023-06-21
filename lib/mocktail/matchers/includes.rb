# typed: strict

module Mocktail::Matchers
  class Includes < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :includes
    end

    sig { params(expecteds: T.untyped).void }
    def initialize(*expecteds)
      @expecteds = T.let(expecteds, T::Array[T.untyped])
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      @expecteds.all? { |expected|
        (actual.respond_to?(:include?) && actual.include?(expected)) ||
          (actual.is_a?(Hash) && expected.is_a?(Hash) && expected.all? { |k, v| actual[k] == v })
      }
    rescue
      false
    end

    sig { returns(String) }
    def inspect
      "#{self.class.matcher_name}(#{@expecteds.map(&:inspect).join(", ")})"
    end
  end
end
