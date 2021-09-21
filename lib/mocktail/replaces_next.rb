module Mocktail
  class ReplacesNext
    def initialize
      @imitates_type = ImitatesType.new.imitate(type)
    end

    def replace(type)
      @imitates_type.imitate(type)
    end
  end
end
