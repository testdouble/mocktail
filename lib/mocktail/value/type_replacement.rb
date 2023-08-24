module Mocktail
  class TypeReplacement < T::Struct
    const :type
    prop :original_methods
    prop :replacement_methods
    prop :original_new
    prop :replacement_new
  end
end
