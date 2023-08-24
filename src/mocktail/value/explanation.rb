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
    sig { override.returns(NoExplanationData) }
    attr_reader :reference

    sig { params(reference: NoExplanationData, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class DoubleExplanation < Explanation
    sig { override.returns(DoubleData) }
    attr_reader :reference

    sig { params(reference: DoubleData, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class ReplacedTypeExplanation < Explanation
    sig { override.returns(TypeReplacementData) }
    attr_reader :reference

    sig { params(reference: TypeReplacementData, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class FakeMethodExplanation < Explanation
    sig { override.returns(FakeMethodData) }
    attr_reader :reference

    sig { params(reference: FakeMethodData, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end
end
