# typed: false

module Mocktail
  FakeMethodData = Struct.new(
    :receiver,
    :calls,
    :stubbings,
    keyword_init: true
  ) do
    include ExplanationData
  end
end
