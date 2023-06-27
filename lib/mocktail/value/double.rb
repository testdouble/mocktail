# typed: strict

module Mocktail
  class Double < T::Struct
    const :original_type
    const :dry_type
    const :dry_instance
    const :dry_methods
  end
end
