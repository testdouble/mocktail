module Mocktail
  class DryCall < Struct.new(
    :double,
    :original_class,
    :method,
    :args,
    :kwargs,
    :blk,
    keyword_init: true
  )
  end
end
