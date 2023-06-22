# typed: strict

module Mocktail::Matchers
  class Base
    extend T::Sig
    extend T::Helpers

    abstract! unless T::Private::RuntimeLevels.default_checked_level == :never

    # Custom matchers can receive any args, kwargs, or block they want. Usually
    # single-argument, though, so that's defaulted here and in #insepct
    sig { params(expected: BasicObject).void }
    def initialize(expected)
      @expected = expected
    end

    sig { returns(Symbol) }
    def self.matcher_name
      raise Mocktail::InvalidMatcherError.new("The `matcher_name` class method must return a valid method name")
    end

    sig { params(actual: BasicObject).returns(T::Boolean) }
    def match?(actual)
      raise Mocktail::InvalidMatcherError.new("Matchers must implement `match?(argument)`")
    end

    sig { returns(String) }
    def inspect
      "#{self.class.matcher_name}(#{T.cast(@expected, Object).inspect})"
    end

    sig { returns(TrueClass) }
    def is_mocktail_matcher?
      true
    end
  end
end
