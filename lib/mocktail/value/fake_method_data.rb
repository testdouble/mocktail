module Mocktail
  class FakeMethodData < Struct.new(
    :receiver,
    :calls,
    :stubbings,
    keyword_init: true
  )
  end
end
