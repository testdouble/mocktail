module Mocktail
  class UnsatisfiedStubbing < Struct.new(
    :call,
    :other_stubbings,
    keyword_init: true
  )
  end
end
