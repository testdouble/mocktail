# typed: strict

module Mocktail
  class TypeReplacement < T::Struct
    const :type, T.any(T::Class[T.anything], Module)
    prop :original_methods, T.nilable(T::Array[Method])
    prop :replacement_methods, T.nilable(T::Array[Method])
    prop :original_new, T.nilable(Method)
    prop :replacement_new, T.nilable(Method)
  end
end
