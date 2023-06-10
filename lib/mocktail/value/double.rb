# typed: true

module Mocktail
  class Double < T::Struct
    const :original_type, T.any(Class, Module)
    const :dry_type, Class
    const :dry_instance, T.anything
    const :dry_methods, T::Array[Symbol]
  end
end
