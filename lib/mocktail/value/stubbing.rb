module Mocktail
  class Stubbing < Struct.new(
    :demonstration,
    :recording,
    :effect,
    keyword_init: true
  )

    def with(&block)
      self.effect = block
    end
  end
end
