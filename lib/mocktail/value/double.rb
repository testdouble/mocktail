module Mocktail
  Double = Struct.new(
    :original_type,
    :dry_type,
    :dry_instance,
    :dry_methods,
    keyword_init: true
  )
end
