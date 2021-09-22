module Mocktail
  class ReplacesType
    def initialize
      @top_shelf = TopShelf.instance
      @handles_dry_call = HandlesDryCall.new
      @handles_dry_new_call = HandlesDryNewCall.new
    end

    def replace(type)
      @top_shelf.register_type_replacement_for_current_thread!(type)
      type_replacement = @top_shelf.type_replacement_for(type)

      if type.is_a?(Class) && !type_replacement&.replacement_new
        handles_dry_new_call = @handles_dry_new_call
        type_replacement.original_new = type.method(:new)
        type.singleton_class.send(:undef_method, :new)
        type.define_singleton_method :new, ->(*args, **kwargs, &block) {
          if TopShelf.instance.replaced_on_current_thread?(type)
            handles_dry_new_call.handle(type, args, kwargs, block)
          else
            type_replacement.original_new.call(*args, **kwargs, &block)
          end
        }
        type_replacement.replacement_new = type.singleton_method(:new)
      end

      if !type_replacement&.replacement_methods
        handles_dry_call = @handles_dry_call
        type_replacement.original_methods = type.singleton_methods.map { |name|
          type.method(name)
        } - [type_replacement.replacement_new]

        type_replacement.replacement_methods = type_replacement.original_methods.map { |original_method|
          type.singleton_class.send(:undef_method, original_method.name)
          type.define_singleton_method original_method.name, ->(*args, **kwargs, &block) {
            if TopShelf.instance.replaced_on_current_thread?(type)
              handles_dry_call.handle(Call.new(
                singleton: true,
                double: type,
                original_type: type,
                dry_type: type,
                method: original_method.name,
                original_method: original_method,
                args: args,
                kwargs: kwargs,
                block: block
              ))
            else
              original_method.call(*args, **kwargs, &block)
            end
          }
          type.singleton_method(original_method.name)
        }
      end
    end
  end
end
