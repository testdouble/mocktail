module Mocktail
  class TypeReplacementData < Struct.new(
    :type,
    :replaced_method_names,
    :calls,
    :stubbings,
    keyword_init: true
  )
    def double
      type
    end
  end
end
