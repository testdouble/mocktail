module Mocktail
  class ReplacesNext
    extend T::Sig

    def initialize
      @top_shelf = TopShelf.instance
      @redefines_new = RedefinesNew.new
      @imitates_type = ImitatesType.new
    end

    def replace_once(type)
      replace(type, 1).fetch(0)
    end

    def replace(type, count)
      raise UnsupportedMocktail.new("Mocktail.of_next() only supports classes") unless type.is_a?(Class)

      mocktails = count.times.map { @imitates_type.imitate(type) }

      @top_shelf.register_of_next_replacement!(type)
      @redefines_new.redefine(type)
      mocktails.reverse_each do |mocktail|
        Mocktail.stubs(
          ignore_extra_args: true,
          ignore_block: true,
          ignore_arity: true,
          times: 1
        ) {
          type.new
        }.with {
          if mocktail == mocktails.last
            @top_shelf.unregister_of_next_replacement!(type)
          end

          mocktail
        }
      end

      mocktails
    end
  end
end
