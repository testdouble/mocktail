# typed: false

module Mocktail::Matchers
  class IncludesKey < Includes
    def self.matcher_name
      :includes_key
    end
  end
end
