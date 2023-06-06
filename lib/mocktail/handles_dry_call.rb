# typed: false

require_relative "handles_dry_call/fulfills_stubbing"
require_relative "handles_dry_call/logs_call"
require_relative "handles_dry_call/validates_arguments"

module Mocktail
  class HandlesDryCall
    def initialize
      @validates_arguments = ValidatesArguments.new
      @logs_call = LogsCall.new
      @fulfills_stubbing = FulfillsStubbing.new
    end

    def handle(dry_call)
      @validates_arguments.validate(dry_call)
      @logs_call.log(dry_call)
      @fulfills_stubbing.fulfill(dry_call)
    end
  end
end
