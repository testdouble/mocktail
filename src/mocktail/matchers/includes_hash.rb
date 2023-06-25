# typed: strict

module Mocktail::Matchers
  class IncludesHash < Includes
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :includes_hash
    end
  end
end
