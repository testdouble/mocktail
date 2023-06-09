# typed: false

module Mocktail
  Stubbing = Struct.new(
    :demonstration,
    :demo_config,
    :satisfaction_count,
    :recording,
    :effect,
    keyword_init: true
  ) do
    class << self
      # Struct defines self.[], but we need to redefine it so that
      # sorbet-runtime can tolerate generic typechecks.
      # See: sorbet/example_consumer/test/sorbet_test.rb
      undef_method(:[])
    end

    def self.[](generic_type_for_sorbet_runtime = nil)
      generic_type_for_sorbet_runtime
    end

    def initialize(**kwargs)
      super
      self.satisfaction_count ||= 0
    end

    def satisfied!
      self.satisfaction_count += 1
    end

    def with(&block)
      self.effect = block
      nil
    end
  end
end
