# typed: strict

module Mocktail
  class TypeReplacementData < T::Struct
    extend T::Sig

    const :type, T.any(T::Class[T.anything], Module)
    const :replaced_method_names, T::Array[Symbol]
    const :calls, T::Array[Call]
    const :stubbings, T::Array[Stubbing[T.anything]]

    include ExplanationData

    def double
      type
    end
  end
end
