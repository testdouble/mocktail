# typed: strict

module Mocktail
  class RedefinesNew
    extend T::Sig

    sig { void }
    def initialize
      @handles_dry_new_call = T.let(HandlesDryNewCall.new, HandlesDryNewCall)
    end

    sig { params(type: T.any(T::Class[T.anything], Module)).void }
    def redefine(type)
      type_replacement = TopShelf.instance.type_replacement_for(type)

      if type_replacement.replacement_new.nil?
        type_replacement.original_new = type.method(:new)
        type.singleton_class.send(:undef_method, :new)
        handles_dry_new_call = @handles_dry_new_call
        type.define_singleton_method :new, ->(*args, **kwargs, &block) {
          if TopShelf.instance.new_replaced?(type) ||
              (type.is_a?(Class) && TopShelf.instance.of_next_registered?(type))
            handles_dry_new_call.handle(T.cast(type, T::Class[T.all(T, Object)]), args, kwargs, block)
          else
            type_replacement.original_new.call(*args, **kwargs, &block)
          end
        }
        type_replacement.replacement_new = type.singleton_method(:new)
      end
    end
  end
end
