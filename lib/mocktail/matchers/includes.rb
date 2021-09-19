module Mocktail::Matchers
  class Includes < Base
    def self.matcher_name
      :includes
    end

    def match?(actual)
      actual.includes?(@expected)
    end
  end
end
