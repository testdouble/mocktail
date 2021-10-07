module Mocktail
  class Explanation
    attr_reader :reference, :message

    def initialize(reference, message)
      @reference = reference
      @message = message
    end

    def type
      self.class
    end
  end

  class NoExplanation < Explanation
  end

  class UnsatisfiedStubExplanation < Explanation
  end

  class DoubleExplanation < Explanation
  end

  class ReplacedTypeExplanation < Explanation
  end
end
