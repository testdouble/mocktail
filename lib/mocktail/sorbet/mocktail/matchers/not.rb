# typed: strict

module Mocktail::Matchers
  class Not < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :not
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      @expected != actual
    end
  end
end
