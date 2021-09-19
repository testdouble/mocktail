module Mocktail
  class Call < Struct.new(
    :double,
    :original_type,
    :dry_type,
    :method,
    :args,
    :kwargs,
    :block,
    keyword_init: true
  )
  end
end
