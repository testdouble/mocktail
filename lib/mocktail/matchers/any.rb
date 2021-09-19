module Mocktail::Matchers
  class Any < Base
    def self.matcher_name
      :any
    end

    def initialize
    end

    def match?(actual)
      true
    end

    def inspect
      "any"
    end
  end
end
