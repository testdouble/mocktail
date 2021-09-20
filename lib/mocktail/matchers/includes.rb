module Mocktail::Matchers
  class Includes < Base
    def self.matcher_name
      :includes
    end

    def match?(actual)
      actual.respond_to?(:include?) && actual.include?(@expected)
    rescue
      false
    end
  end
end
