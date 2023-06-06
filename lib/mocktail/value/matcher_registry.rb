# typed: false

module Mocktail
  class MatcherRegistry
    def self.instance
      @matcher_registry ||= new
    end

    def initialize
      @matchers = {}
    end

    def add(matcher_type)
      @matchers[matcher_type.matcher_name] = matcher_type
    end

    def get(name)
      @matchers[name]
    end
  end
end
