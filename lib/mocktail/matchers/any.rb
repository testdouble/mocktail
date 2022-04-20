module Mocktail::Matchers
  class Any < Base
    def self.matcher_name
      :any
    end

    # Change this comment to a descriptive one once this is merged:
    # https://github.com/rubocop/rubocop/pull/10551
    def initialize # standard:disable Style/RedundantInitialize
    end

    def match?(actual)
      true
    end

    def inspect
      "any"
    end
  end
end
