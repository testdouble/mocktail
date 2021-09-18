require_relative "verifies_call/finds_matching_call"
require_relative "verifies_call/raises_verification_error"

module Mocktail
  class VerifiesCall
    def self.instance
      @verifies_call ||= new
    end

    def initialize
      @finds_matching_call = FindsMatchingCall.new
      @raises_verification_error = RaisesVerificationError.new
    end

    def verify(demo)
    end
  end
end
