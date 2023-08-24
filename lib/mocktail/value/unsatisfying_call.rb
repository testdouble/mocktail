module Mocktail
  class UnsatisfyingCall < T::Struct
    const :call
    const :other_stubbings
    const :backtrace
  end
end
