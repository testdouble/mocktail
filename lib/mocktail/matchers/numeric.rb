module Mocktail::Matchers
  class Numeric < Base
    def self.matcher_name
      :numeric
    end

    def initialize
    end

    def match?(actual)
      [Integer, Float, (BigDecimal if defined?(BigDecimal))].include?(actual)
    end

    def inspect
      "numeric"
    end
  end
end
