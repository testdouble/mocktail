module Mocktail::Matchers
  class Matches < Base
    def self.matcher_name
      :matches
    end

    def match?(actual)
      actual.matches?(@expected)
    end
  end
end
