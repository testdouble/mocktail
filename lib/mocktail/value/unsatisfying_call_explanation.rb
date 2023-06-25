# typed: strict

module Mocktail
  class UnsatisfyingCallExplanation
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
end
