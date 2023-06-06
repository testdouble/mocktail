# typed: false

module Mocktail::Matchers
  class Base
    # Custom matchers can receive any args, kwargs, or block they want. Usually
    # single-argument, though, so that's defaulted here and in #insepct
    def initialize(expected)
      @expected = expected
    end

    def self.matcher_name
      raise Mocktail::Error.new("The `matcher_name` class method must return a valid method name")
    end

    def match?(actual)
      raise Mocktail::Error.new("Matchers must implement `match?(argument)`")
    end

    def inspect
      "#{self.class.matcher_name}(#{@expected.inspect})"
    end

    def is_mocktail_matcher?
      true
    end
  end
end
