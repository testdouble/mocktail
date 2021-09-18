module Mocktail
  class Stubbing < Struct.new(
    :demonstration,
    :recording,
    :effect,
    keyword_init: true
  )

    def with(&blk)
      self.effect = blk
    end
  end
end
