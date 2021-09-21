module Mocktail
  class TypeReplacement < Struct.new(
    :type,
    :original_methods,
    :replacement_methods,
    keyword_init: true
  )
  end
end
