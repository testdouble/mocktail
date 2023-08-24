# typed: strict

module Mocktail::Matchers
  class Numeric < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :numeric
    end

    sig { void }
    def initialize
      # Empty initialize is necessary b/c Base default expects an argument
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      actual.is_a?(::Numeric)
    end

    sig { returns(String) }
    def inspect
      "numeric"
    end
  end
end
