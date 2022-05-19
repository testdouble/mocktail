# typed: ignore
module Mocktail
  class UnsatisfyingCall < Struct.new(
    :call,
    :other_stubbings,
    :backtrace,
    keyword_init: true
  )
  end
end
