module Mocktail
  class ReplacesNext
    def initialize
      @top_shelf = TopShelf.instance
      @redefines_new = RedefinesNew.new
      @imitates_type = ImitatesType.new
    end

    def replace(type, count)
      mocktails = count.times.map { @imitates_type.imitate(type) }

      @top_shelf.register_of_next_replacement!(type)
      @redefines_new.redefine(type)
      mocktails.reverse.each.with_index do |mocktail, i|
        Mocktail.stubs(
          ignore_extra_args: true,
          ignore_block: true,
          ignore_arity: true,
          times: 1
        ) {
          type.new
        }.with {
          if i + 1 == mocktails.size
            @top_shelf.unregister_of_next_replacement!(type)
          end

          mocktail
        }
      end

      mocktails.size == 1 ? mocktails.first : mocktails
    end
  end
end
