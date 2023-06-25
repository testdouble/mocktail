# typed: strict

module Mocktail::Matchers
  class IncludesString < Includes
    extend T::Sig

    def self.matcher_name
      :includes_string
    end
  end
end
