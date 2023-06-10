# typed: true

module Mocktail
  class Stubbing < T::Struct
    extend T::Sig
    extend T::Generic
    MethodReturnType = type_member

    const :demonstration, T.proc.params(matchers: Mocktail::MatcherPresentation).returns(MethodReturnType)
    const :demo_config, DemoConfig
    prop :satisfaction_count, Integer, default: 0
    const :recording, Call
    prop :effect, T.nilable(T.proc.params(call: Mocktail::Call).returns(MethodReturnType))

    sig { void }
    def satisfied!
      self.satisfaction_count += 1
    end

    sig { params(block: T.proc.params(call: Mocktail::Call).returns(MethodReturnType)).void }
    def with(&block)
      self.effect = block
      nil
    end
  end
end
