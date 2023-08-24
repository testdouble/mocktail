# typed: strict

module Mocktail
  class NoExplanationData < T::Struct
    extend T::Sig
    include ExplanationData

    const :thing, Object

    sig { override.returns(T::Array[Mocktail::Call]) }
    def calls
      raise Error.new("No calls have been recorded for #{thing.inspect}, because Mocktail doesn't know what it is.")
    end

    sig { override.returns T::Array[Mocktail::Stubbing[T.anything]] }
    def stubbings
      raise Error.new("No stubbings exist on #{thing.inspect}, because Mocktail doesn't know what it is.")
    end
  end
end
