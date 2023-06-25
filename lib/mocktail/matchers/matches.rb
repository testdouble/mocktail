# typed: strict

module Mocktail::Matchers
  class Matches < Base
    extend T::Sig

    def self.matcher_name
      :matches
    end

    def match?(actual)
      actual.respond_to?(:match?) && actual.match?(@expected)
    rescue
      false
    end
  end
end
