# typed: strict

module Mocktail
  class FakeMethodData < T::Struct
    include ExplanationData

    const :receiver, T.anything
    const :calls, T::Array[Call]
    const :stubbings, T::Array[Stubbing[T.untyped]]
  end
end
