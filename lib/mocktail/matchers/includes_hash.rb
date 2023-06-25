# typed: strict

module Mocktail::Matchers
  class IncludesHash < Includes
    extend T::Sig

    def self.matcher_name
      :includes_hash
    end
  end
end
