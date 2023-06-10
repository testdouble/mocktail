# typed: true

require_relative "call"
require_relative "stubbing"

module Mocktail
  class DoubleData < T::Struct
    include ExplanationData

    const :type, T.any(Class, Module)
    const :double, T.anything
    const :calls, T::Array[Call]
    const :stubbings, T::Array[Stubbing[T.untyped]]
  end
end
