# typed: strict

module Mocktail
  class Stubbing < T::Struct
    extend T::Sig
    extend T::Generic
    MethodReturnType = type_member

    const :demonstration
    const :demo_config
    prop :satisfaction_count, default: 0
    const :recording
    prop :effect

    def satisfied!
      self.satisfaction_count += 1
    end

    def with(&block)
      self.effect = block
      nil
    end
  end
end
