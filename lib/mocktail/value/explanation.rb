module Mocktail
  class Explanation
    extend T::Sig

    attr_reader :reference

    attr_reader :message

    def initialize(reference, message)
      @reference = reference
      @message = message
    end

    def type
      self.class
    end
  end

  class NoExplanation < Explanation
    attr_reader :reference

    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class DoubleExplanation < Explanation
    attr_reader :reference

    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class ReplacedTypeExplanation < Explanation
    attr_reader :reference

    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end

  class FakeMethodExplanation < Explanation
    attr_reader :reference

    def initialize(reference, message)
      @reference = reference
      @message = message
    end
  end
end
