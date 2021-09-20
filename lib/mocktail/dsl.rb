module Mocktail
  module DSL
    def stubs(ignore_blocks: false, ignore_extra_args: false, &demo)
      RegistersStubbing.instance.register(demo, DemoConfig.new(ignore_blocks: ignore_blocks, ignore_extra_args: ignore_extra_args))
    end

    def verify(ignore_blocks: false, ignore_extra_args: false, &demo)
      VerifiesCall.instance.verify(demo, DemoConfig.new(ignore_blocks: ignore_blocks, ignore_extra_args: ignore_extra_args))
    end
  end
end
