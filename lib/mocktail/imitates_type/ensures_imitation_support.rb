# typed: true

module Mocktail
  class EnsuresImitationSupport
    def ensure(type)
      unless type.is_a?(Class) || type.is_a?(Module)
        raise UnsupportedMocktail.new <<~MSG.tr("\n", " ")
          Mocktail.of() can only mix mocktail instances of modules and classes.
        MSG
      end
    end
  end
end
