# typed: strict

module Mocktail::Matchers
  class IsA < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :is_a
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      actual.is_a?(@expected)
    end
  end
end
