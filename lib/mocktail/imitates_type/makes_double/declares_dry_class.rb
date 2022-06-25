module Mocktail
  class DeclaresDryClass
    def initialize
      @handles_dry_call = HandlesDryCall.new
      @raises_neato_no_method_error = RaisesNeatoNoMethodError.new
    end

    def declare(type, instance_methods)
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

      # These have special implementations, but if the user defines
      # any of them on the object itself, then they'll be replaced with normal
      # mocked methods. YMMV
      add_stringify_methods!(dry_class, :to_s, type, instance_methods)
      add_stringify_methods!(dry_class, :inspect, type, instance_methods)
      define_method_missing_errors!(dry_class, type, instance_methods)

      define_double_methods!(dry_class, type, instance_methods)

      dry_class
    end

    private

    def define_double_methods!(dry_class, type, instance_methods)
      handles_dry_call = @handles_dry_call
      instance_methods.each do |method|
        dry_class.undef_method(method) if dry_class.method_defined?(method)

        dry_class.define_method method, ->(*args, **kwargs, &block) {
          Debug.guard_against_mocktail_accidentally_calling_mocks_if_debugging!
          handles_dry_call.handle(Call.new(
            singleton: false,
            double: self,
            original_type: type,
            dry_type: dry_class,
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

    def define_method_missing_errors!(dry_class, type, instance_methods)
      return if instance_methods.include?(:method_missing)

      raises_neato_no_method_error = @raises_neato_no_method_error
      dry_class.define_method :method_missing, ->(name, *args, **kwargs, &block) {
        raises_neato_no_method_error.call(
          Call.new(
            singleton: false,
            double: self,
            original_type: type,
            dry_type: self.class,
            method: name,
            original_method: nil,
            args: args,
            kwargs: kwargs,
            block: block
          )
        )
      }
    end
  end
end
