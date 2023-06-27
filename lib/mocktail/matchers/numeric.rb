module Mocktail::Matchers
  class Numeric < Base
    extend T::Sig

    def self.matcher_name
      :numeric
    end

    def initialize
      # Empty initialize is necessary b/c Base default expects an argument
    end

    def match?(actual)
      actual.is_a?(::Numeric)
    end

    def inspect
      "numeric"
    end
  end
end
