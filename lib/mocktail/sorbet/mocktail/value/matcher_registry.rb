# typed: strict

module Mocktail
  class MatcherRegistry
    extend T::Sig

    sig { returns(MatcherRegistry) }
    def self.instance
      @matcher_registry ||= T.let(new, T.nilable(T.attached_class))
    end

    sig { void }
    def initialize
      @matchers = T.let({}, T::Hash[Symbol, T.class_of(Matchers::Base)])
    end

    sig { params(matcher_type: T.class_of(Matchers::Base)).void }
    def add(matcher_type)
      @matchers[matcher_type.matcher_name] = matcher_type
    end

    sig { params(name: Symbol).returns(T.nilable(T.class_of(Matchers::Base))) }
    def get(name)
      @matchers[name]
    end
  end
end
