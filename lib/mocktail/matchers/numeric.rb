module Mocktail::Matchers
  class Numeric < Base
    def self.matcher_name
      :numeric
    end

    # Change this comment to a descriptive one once this is merged:
    # https://github.com/rubocop/rubocop/pull/10551
    def initialize # standard:disable Style/RedundantInitialize
    end

    def match?(actual)
      [Integer, Float, (BigDecimal if defined?(BigDecimal))].include?(actual.class)
    end

    def inspect
      "numeric"
    end
  end
end
