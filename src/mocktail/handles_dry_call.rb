# typed: strict

require_relative "handles_dry_call/fulfills_stubbing"
require_relative "handles_dry_call/logs_call"
require_relative "handles_dry_call/validates_arguments"

module Mocktail
  class HandlesDryCall
    extend T::Sig

    sig { void }
    def initialize
      @validates_arguments = T.let(ValidatesArguments.new, ValidatesArguments)
      @logs_call = T.let(LogsCall.new, LogsCall)
      @fulfills_stubbing = T.let(FulfillsStubbing.new, FulfillsStubbing)
    end

    sig { params(dry_call: Call).returns(T.anything) }
    def handle(dry_call)
      @validates_arguments.validate(dry_call)
      @logs_call.log(dry_call)
      @fulfills_stubbing.fulfill(dry_call)
    end
  end
end
