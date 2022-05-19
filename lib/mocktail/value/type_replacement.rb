# typed: false
module Mocktail
  TypeReplacement = Struct.new(
    :type,
    :original_methods,
    :replacement_methods,
    :original_new,
    :replacement_new,
    keyword_init: true
  )
end
