# typed: true

module Mocktail::Matchers
  class Matches < Base
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
