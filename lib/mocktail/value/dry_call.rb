module Mocktail
  class DryCall < Struct.new(
    :double,
    :original_type,
    :dry_type,
    :method,
    :args,
    :kwargs,
    :blk,
    keyword_init: true
  )
  end
end
