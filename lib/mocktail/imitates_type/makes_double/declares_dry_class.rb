module Mocktail
  class DeclaresDryClass
    def initialize
      @handles_dry_call = HandlesDryCall.new
    end

    def declare(type)
      type_type = type_of(type)
      instance_methods = instance_methods_on(type)
      dry_class = Class.new(type_type == :class ? type : Object) {
        include type if type_type == :module

        def initialize(*args, **kwargs, &blk)
        end
      }

      add_stringify_methods!(dry_class, :to_s, type, type_type, instance_methods)
      add_stringify_methods!(dry_class, :inspect, type, type_type, instance_methods)

      define_double_methods!(dry_class, type, instance_methods)

      dry_class
    end

    private

    def define_double_methods!(dry_class, type, instance_methods)
      handles_dry_call = @handles_dry_call
      instance_methods.each do |method|
        dry_class.define_method method, ->(*args, **kwargs, &block) {
          handles_dry_call.handle(Call.new(
            double: self,
            original_type: type,
            dry_type: self.class,
            method: method,
            args: args,
            kwargs: kwargs,
            block: block
          ))
        }
      end
    end

    def add_stringify_methods!(dry_class, method_name, type, type_type, instance_methods)
      dry_class.define_singleton_method method_name, -> {
        if (id_matches = super().match(/:([0-9a-fx]+)>$/))
          "#<Class #{"including module " if type_type == :module}for mocktail of #{type.name}:#{id_matches[1]}>"
        else
          super()
        end
      }

      unless instance_methods.include?(method_name)
        dry_class.define_method method_name, -> {
          if (id_matches = super().match(/:([0-9a-fx]+)>$/))
            "#<Mocktail of #{type.name}:#{id_matches[1]}>"
          else
            super()
          end
        }
      end
    end

    def type_of(type)
      if type.is_a?(Class)
        :class
      elsif type.is_a?(Module)
        :module
      end
    end

    def instance_methods_on(type)
      type.instance_methods.reject { |m|
        ignored_ancestors.include?(type.instance_method(m).owner)
      }
    end

    def ignored_ancestors
      Object.ancestors
    end
  end
end
