# typed: strict

module Mocktail::Matchers
  class IsA < Base
    extend T::Sig

    def self.matcher_name
      :is_a
    end

    def match?(actual)
      actual.is_a?(@expected)
    end
  end
end
