# typed: strict

module Mocktail::Matchers
  class IncludesKey < Includes
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :includes_key
    end
  end
end
