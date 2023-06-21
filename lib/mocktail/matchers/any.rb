# typed: strict

module Mocktail::Matchers
  class Any < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :any
    end

    sig { void }
    def initialize
      # Empty initialize is necessary b/c Base default expects an argument
    end

    sig { params(actual: T.anything).returns(T::Boolean) }
    def match?(actual)
      true
    end

    sig { returns(String) }
    def inspect
      "any"
    end
  end
end
