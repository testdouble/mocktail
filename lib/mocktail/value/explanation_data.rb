# typed: strict

module Mocktail
  module ExplanationData
    extend T::Helpers
    extend T::Sig

    interface!
    requires_ancestor { Kernel }

    sig { abstract.returns T::Array[Mocktail::Call] }
    def calls
    end

    sig { abstract.returns T::Array[Mocktail::Stubbing[T.untyped]] }
    def stubbings
    end
  end
end
