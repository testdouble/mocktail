# typed: strict

module Mocktail
  class ReplacesNext
    extend T::Sig

    sig { void }
    def initialize
      @top_shelf = T.let(TopShelf.instance, TopShelf)
      @redefines_new = T.let(RedefinesNew.new, RedefinesNew)
      @imitates_type = T.let(ImitatesType.new, ImitatesType)
    end

    sig {
      type_parameters(:T)
        .params(type: T::Class[T.all(T.type_parameter(:T), Object)])
        .returns(T.type_parameter(:T))
    }
    def replace_once(type)
      replace(type, 1).fetch(0)
    end

    sig {
      type_parameters(:T)
        .params(type: T::Class[T.all(T.type_parameter(:T), Object)], count: Integer)
        .returns(T::Array[T.type_parameter(:T)])
    }
    def replace(type, count)
      raise UnsupportedMocktail.new("Mocktail.of_next() only supports classes") unless T.unsafe(type).is_a?(Class)

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
