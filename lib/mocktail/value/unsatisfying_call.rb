# typed: false
module Mocktail
  UnsatisfyingCall = Struct.new(
    :call,
    :other_stubbings,
    :backtrace,
    keyword_init: true
  )
end
