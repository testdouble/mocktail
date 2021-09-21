module Mocktail
  class TypeReplacement < Struct.new(
    :type,
    :original_methods,
    :replacement_methods,
    keyword_init: true
  )
  end

  class TopShelf
    def self.instance
      @self ||= new
    end

    def initialize
      @type_replacements = {}
      @registrations = {}
    end

    def already_replaced?(type)
      !!@type_replacements[type]
    end

    def store_type_replacement(type_replacement)
      @type_replacements[type_replacement.type] = type_replacement
    end

    def type_replacement_for(type)
      @type_replacements[type]
    end

    def replaced_on_current_thread?(type)
      @registrations[Thread.current] ||= []
      @registrations[Thread.current].include?(type)
    end

    def register_type_replacement_for_current_thread!(type)
      @registrations[Thread.current] ||= []
      @registrations[Thread.current] |= [type]
    end

    def reset_type_replacement_for_current_thread!
      @registrations[Thread.current] = []
    end
  end

  class ReplacesType
    def initialize
      @top_shelf = TopShelf.instance
      @handles_dry_call = HandlesDryCall.new
      # @imitates_type = ImitatesType.new.imitate(type)
    end

    def replace(type)
      if !@top_shelf.already_replaced?(type)
        original_methods = (
          [:new] + type.singleton_methods
        ).map { |name| [name, type.method(name)] }.to_h

        handles_dry_call = @handles_dry_call
        replacement_methods = original_methods.map { |name, original_method|
          type.singleton_class.send(:undef_method, name)
          type.define_singleton_method name, ->(*args, **kwargs, &block) {
            if TopShelf.instance.replaced_on_current_thread?(type)
              handles_dry_call.handle(Call.new(
                singleton: true,
                double: type,
                original_type: type,
                dry_type: type,
                method: name,
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
          replacement_methods: replacement_methods
        ))
      end
      @top_shelf.register_type_replacement_for_current_thread!(type)

      # @imitates_type.imitate(type)
    end
  end
end
