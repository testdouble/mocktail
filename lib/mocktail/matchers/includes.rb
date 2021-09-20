module Mocktail::Matchers
  class Includes < Base
    def self.matcher_name
      :includes
    end

    def initialize(*expecteds)
      @expecteds = expecteds
    end

    def match?(actual)
      @expecteds.all? { |expected|
        (actual.respond_to?(:include?) && actual.include?(expected)) ||
          (actual.is_a?(Hash) && expected.is_a?(Hash) && expected.all? { |k, v| actual[k] == v })
      }
    rescue
      false
    end

    def inspect
      "#{self.class.matcher_name}(#{@expecteds.map(&:inspect).join(", ")})"
    end
  end
end
