module Mocktail
  class DeclaresDryClass
    def initialize
      @handles_dry_call = HandlesDryCall.new
    end

    def declare(type)
      instance_methods = instance_methods_on(type)
      dry_class = Class.new(Object) {
        include type if type.instance_of?(Module)

        def initialize(*args, **kwargs, &blk)
        end

        define_method :is_a?, ->(thing) {
          type.ancestors.include?(thing)
        }
        alias_method :kind_of?, :is_a?

        if type.instance_of?(Class)
          define_method :instance_of?, ->(thing) {
            type == thing
          }
        end
      }

      add_stringify_methods!(dry_class, :to_s, type, instance_methods)
      add_stringify_methods!(dry_class, :inspect, type, instance_methods)

      define_double_methods!(dry_class, type, instance_methods)

      dry_class
    end

    private

    def define_double_methods!(dry_class, type, instance_methods)
      handles_dry_call = @handles_dry_call
      instance_methods.each do |method|
        dry_class.define_method method, ->(*args, **kwargs, &block) {
          handles_dry_call.handle(Call.new(
            singleton: false,
            double: self,
            original_type: type,
            dry_type: self.class,
            method: method,
            original_method: type.instance_method(method),
            args: args,
            kwargs: kwargs,
            block: block
          ))
        }
      end
    end

    def add_stringify_methods!(dry_class, method_name, type, instance_methods)
      dry_class.define_singleton_method method_name, -> {
        if (id_matches = super().match(/:([0-9a-fx]+)>$/))
          "#<Class #{"including module " if type.instance_of?(Module)}for mocktail of #{type.name}:#{id_matches[1]}>"
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
