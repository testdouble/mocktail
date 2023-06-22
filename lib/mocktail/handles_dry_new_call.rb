# typed: strict

module Mocktail
  class HandlesDryNewCall
    extend T::Sig

    sig { void }
    def initialize
      @validates_arguments = T.let(ValidatesArguments.new, ValidatesArguments)
      @logs_call = T.let(LogsCall.new, LogsCall)
      @fulfills_stubbing = T.let(FulfillsStubbing.new, FulfillsStubbing)
      @imitates_type = T.let(ImitatesType.new, ImitatesType)
    end

    sig { params(type: T::Class[T.anything], args: T::Array[T.anything], kwargs: T::Hash[Symbol, T.anything], block: T.nilable(Proc)).returns(T.anything) }
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
