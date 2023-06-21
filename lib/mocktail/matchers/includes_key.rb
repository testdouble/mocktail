# typed: true

module Mocktail::Matchers
  class IncludesKey < Includes
    def self.matcher_name
      :includes_key
    end
  end
end
