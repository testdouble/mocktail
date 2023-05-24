# typed: true

module Mocktail
  TypeReplacementData = Struct.new(
    :type,
    :replaced_method_names,
    :calls,
    :stubbings,
    keyword_init: true
  ) do
    def double
      type
    end
  end
end
