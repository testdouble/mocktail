module Mocktail
  class ReplacesType
    def initialize
      @top_shelf = TopShelf.instance
      @handles_dry_call = HandlesDryCall.new
      @handles_dry_new_call = HandlesDryNewCall.new
    end

    def replace(type)
      @top_shelf.register_type_replacement_for_current_thread!(type)

      if !@top_shelf.already_replaced?(type)
        original_methods = type.singleton_methods.map { |name| type.method(name) }

        handles_dry_new_call = @handles_dry_new_call
        if type.is_a?(Class)
          original_new = type.method(:new)
          type.singleton_class.send(:undef_method, :new)
          replacement_new = type.define_singleton_method :new, ->(*args, **kwargs, &block) {
            if TopShelf.instance.replaced_on_current_thread?(type)
              handles_dry_new_call.handle(type, args, kwargs, block)
            else
              original_new.call(*args, **kwargs, &block)
            end
          }
        end

        handles_dry_call = @handles_dry_call
        replacement_methods = original_methods.map { |original_method|
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
        }

        @top_shelf.store_type_replacement(TypeReplacement.new(
          type: type,
          original_methods: original_methods,
          replacement_methods: replacement_methods,
          original_new: original_new,
          replacement_new: replacement_new
        ))
      end
    end
  end
end
