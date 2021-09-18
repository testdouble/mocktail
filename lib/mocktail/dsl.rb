module Mocktail
  module DSL
    def stubs(&demo)
      RegistersStubbing.instance.register(demo)
    end

    def verify(&demo)
      VerifiesCall.instance.verify(demo)
    end
  end
end
