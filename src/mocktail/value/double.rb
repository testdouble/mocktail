# typed: strict

module Mocktail
  class Double < T::Struct
    const :original_type, T.any(T::Class[T.anything], Module)
    const :dry_type, T::Class[T.anything]
    const :dry_instance, T.untyped
    const :dry_methods, T::Array[Symbol]
  end
end
