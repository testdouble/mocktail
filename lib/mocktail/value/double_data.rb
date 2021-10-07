module Mocktail
  class DoubleData < Struct.new(
    :type,
    :double,
    :calls,
    :stubbings,
    keyword_init: true
  )
  end
end
