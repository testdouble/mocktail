# typed: strict

module Mocktail::Matchers
  class Any < Base
    extend T::Sig

    def self.matcher_name
      :any
    end

    def initialize
      # Empty initialize is necessary b/c Base default expects an argument
    end

    def match?(actual)
      true
    end

    def inspect
      "any"
    end
  end
end
