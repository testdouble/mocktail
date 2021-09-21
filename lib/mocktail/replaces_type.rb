module Mocktail
  class ReplacesType
    def initialize
      @top_shelf = TopShelf.instance
      @handles_dry_call = HandlesDryCall.new

      @registers_stubbing = RegistersStubbing.new
      @imitates_type = ImitatesType.new
      @validates_arguments = ValidatesArguments.new
      @logs_call = LogsCall.new
    end

    def replace(type)
      @top_shelf.register_type_replacement_for_current_thread!(type)

      if !@top_shelf.already_replaced?(type)
        original_methods = (
          [:new] + type.singleton_methods
        ).map { |name| [name, type.method(name)] }.to_h

        handles_dry_call = @handles_dry_call
        validates_arguments = @validates_arguments
        imitates_type = @imitates_type
        logs_call = @logs_call

        type.singleton_class.send(:undef_method, :new)
        new_new_method = type.define_singleton_method :new, ->(*args, **kwargs, &block) {
          if TopShelf.instance.replaced_on_current_thread?(type)
            validates_arguments.validate(Call.new(
              original_method: type.instance_method(:initialize),
              args: args,
              kwargs: kwargs
            ))
            logs_call.log(Call.new(
              singleton: true,
              double: type,
              original_type: type,
              dry_type: type,
              method: :new,
              original_method: original_methods[:new],
              args: args,
              kwargs: kwargs,
              block: block
            ))
            imitates_type.imitate(type)

            # ValidatesArguments.optional(true) do
            #   Mocktail.cabinet.dry_type_of(type).new
            # end

          else
            original_methods[:new].call(*args, **kwargs, &block)
          end
        }

        replacement_methods = original_methods.map { |name, original_method|
          next if name == :new

          type.singleton_class.send(:undef_method, name)
          type.define_singleton_method name, ->(*args, **kwargs, &block) {
            if TopShelf.instance.replaced_on_current_thread?(type)
              handles_dry_call.handle(Call.new(
                singleton: true,
                double: type,
                original_type: type,
                dry_type: type,
                method: name,
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

        #         @registers_stubbing.register(
        #           proc { type.new },
        #           DemoConfig.new(
        #             ignore_extra_args: true,
        #             ignore_blocks: true,
        #             ignore_arity: true
        #           )
        #         ).with {
        #           ValidatesArguments.optional(true) do
        #             @#
        #             imitates_type.imitate(type)
        #           end
        #         }

        @top_shelf.store_type_replacement(TypeReplacement.new(
          type: type,
          original_methods: original_methods,
          replacement_methods: [new_new_method] + replacement_methods
        ))
      end
    end
  end
end
