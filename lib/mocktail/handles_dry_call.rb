module Mocktail
  class HandlesDryCall
    def self.instance
      @self ||= new
    end

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
