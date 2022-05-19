# typed: true
module Mocktail
  module DSL
    def stubs(ignore_block: false, ignore_extra_args: false, ignore_arity: false, times: nil, &demo)
      RegistersStubbing.new.register(demo, DemoConfig.new(
        ignore_block: ignore_block,
        ignore_extra_args: ignore_extra_args,
        ignore_arity: ignore_arity,
        times: times
      ))
    end

    def verify(ignore_block: false, ignore_extra_args: false, ignore_arity: false, times: nil, &demo)
      VerifiesCall.new.verify(demo, DemoConfig.new(
        ignore_block: ignore_block,
        ignore_extra_args: ignore_extra_args,
        ignore_arity: ignore_arity,
        times: times
      ))
    end
  end
end
