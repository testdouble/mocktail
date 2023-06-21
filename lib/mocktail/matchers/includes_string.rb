# typed: true

module Mocktail::Matchers
  class IncludesString < Includes
    def self.matcher_name
      :includes_string
    end
  end
end
