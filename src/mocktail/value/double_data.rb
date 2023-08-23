# typed: strict

require_relative "call"
require_relative "stubbing"

module Mocktail
  class DoubleData < T::Struct
    include ExplanationData

    const :type, T.any(T::Class[T.anything], Module)
    const :double, Object
    const :calls, T::Array[Call]
    const :stubbings, T::Array[Stubbing[T.anything]]
  end
end
