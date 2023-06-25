# typed: strict

module Mocktail
  class UnsatisfyingCallExplanation
    extend T::Sig

    sig { returns(UnsatisfyingCall) }
    attr_reader :reference

    sig { returns(String) }
    attr_reader :message

    sig { params(reference: UnsatisfyingCall, message: String).void }
    def initialize(reference, message)
      @reference = reference
      @message = message
    end

    sig { returns(T.class_of(UnsatisfyingCallExplanation)) }
    def type
      self.class
    end
  end
end
