module Mocktail
  module DSL
    def stubs(&demo) # .with {}
      RegistersStubbing.instance.register(demo)
    end
  end
end
