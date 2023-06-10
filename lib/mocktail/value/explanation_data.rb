# typed: strict

module Mocktail
  module ExplanationData
    extend T::Helpers
    extend T::Sig

    interface!
    include Kernel

    sig { abstract.returns T::Array[Mocktail::Call] }
    def calls
    end

    sig { abstract.returns T::Array[Mocktail::Stubbing[T.untyped]] }
    def stubbings
    end
  end
end
