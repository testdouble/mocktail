module Mocktail
  class FakeMethodData < T::Struct
    include ExplanationData

    const :receiver
    const :calls
    const :stubbings
  end
end
