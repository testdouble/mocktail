# typed: strict

module Mocktail::Matchers
  class IncludesString < Includes
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :includes_string
    end
  end
end
