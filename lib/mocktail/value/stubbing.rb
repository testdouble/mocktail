# typed: ignore
module Mocktail
  class Stubbing < Struct.new(
    :demonstration,
    :demo_config,
    :satisfaction_count,
    :recording,
    :effect,
    keyword_init: true
  )

    def initialize(**kwargs)
      super
      self.satisfaction_count ||= 0
    end

    def satisfied!
      self.satisfaction_count += 1
    end

    def with(&block)
      self.effect = block
    end
  end
end
