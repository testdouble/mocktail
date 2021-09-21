module Mocktail
  module DSL
    def stubs(ignore_blocks: false, ignore_extra_args: false, times: nil, &demo)
      RegistersStubbing.new.register(demo, DemoConfig.new(
        ignore_blocks: ignore_blocks,
        ignore_extra_args: ignore_extra_args,
        times: times
      ))
    end

    def verify(ignore_blocks: false, ignore_extra_args: false, times: nil, &demo)
      VerifiesCall.new.verify(demo, DemoConfig.new(
        ignore_blocks: ignore_blocks,
        ignore_extra_args: ignore_extra_args,
        times: times
      ))
    end
  end
end
