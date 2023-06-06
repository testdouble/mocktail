# typed: false

module Mocktail
  DoubleData = Struct.new(
    :type,
    :double,
    :calls,
    :stubbings,
    keyword_init: true
  )
end
