# typed: strict

module Mocktail
  class Explanation
    extend T::Sig

    sig { returns(Mocktail::ExplanationData) }
    attr_reader :reference

    sig { returns(String) }
    attr_reader :message

    sig { params(reference: Mocktail::ExplanationData, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end

    sig { returns(T.class_of(Explanation)) }
    def type
      self.class
    end
  end

  class NoExplanation < Explanation
  end

  class DoubleExplanation < Explanation
  end

  class ReplacedTypeExplanation < Explanation
  end

  class FakeMethodExplanation < Explanation
  end
end
