# typed: true
module Mocktail
  Call = Struct.new(
    :singleton,
    :double,
    :original_type,
    :dry_type,
    :method,
    :original_method,
    :args,
    :kwargs,
    :block,
    keyword_init: true
  )
end
