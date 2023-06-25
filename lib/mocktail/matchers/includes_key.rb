# typed: strict

module Mocktail::Matchers
  class IncludesKey < Includes
    extend T::Sig

    def self.matcher_name
      :includes_key
    end
  end
end
