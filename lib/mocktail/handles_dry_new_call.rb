# typed: strict

module Mocktail
  class HandlesDryNewCall
    extend T::Sig

    def initialize
      @validates_arguments = ValidatesArguments.new
      @logs_call = LogsCall.new
      @fulfills_stubbing = FulfillsStubbing.new
      @imitates_type = ImitatesType.new
    end

    def handle(type, args, kwargs, block)
      @validates_arguments.validate(Call.new(
        original_method: type.instance_method(:initialize),
        args: args,
        kwargs: kwargs,
        block: block
      ))

      new_call = Call.new(
        singleton: true,
        double: type,
        original_type: type,
        dry_type: type,
        method: :new,
        args: args,
        kwargs: kwargs,
        block: block
      )
      @logs_call.log(new_call)
      if @fulfills_stubbing.satisfaction(new_call)
        @fulfills_stubbing.fulfill(new_call)
      else
        @imitates_type.imitate(type)
      end
    end
  end
end
