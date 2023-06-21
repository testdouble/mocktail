# typed: strict

module Mocktail::Matchers
  class Matches < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :matches
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      actual.respond_to?(:match?) && actual.match?(@expected)
    rescue
      false
    end
  end
end
