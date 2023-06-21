# typed: true

module Mocktail
  NoExplanationData = Struct.new(
    :thing,
    keyword_init: true
  ) do
    include ExplanationData

    def calls
      raise Error.new("No calls have been recorded for #{thing.inspect}, because Mocktail doesn't know what it is.")
    end

    def stubbings
      raise Error.new("No stubbings exist on #{thing.inspect}, because Mocktail doesn't know what it is.")
    end
  end
end
