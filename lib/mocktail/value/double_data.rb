# typed: strict

require_relative "call"
require_relative "stubbing"

module Mocktail
  class DoubleData < T::Struct
    include ExplanationData

    const :type
    const :double
    const :calls
    const :stubbings
  end
end
