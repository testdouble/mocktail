module Mocktail
  class UnsatisfyingCall < Struct.new(
    :call,
    :other_stubbings,
    keyword_init: true
  )
  end
end
