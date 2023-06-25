# typed: strict

module Mocktail
  class UnsatisfyingCall < T::Struct
    const :call, Call
    const :other_stubbings, T::Array[Stubbing[T.anything]]
    const :backtrace, T::Array[String]
  end
end
