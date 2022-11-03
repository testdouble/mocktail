module Mocktail
  class DeclaresDryClass
    def initialize
      @handles_dry_call = HandlesDryCall.new
      @raises_neato_no_method_error = RaisesNeatoNoMethodError.new
      @transforms_params = TransformsParams.new
      @builds_method_signature = BuildsMethodSignature.new
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
        parameters = type.instance_method(method).parameters
        signature = @transforms_params.transform(Call.new, params: parameters)
        method_signature = @builds_method_signature.build(signature)

        # TODO: This is failing because none of self, type, dry_class, method,
        # etc are in scope for the dry_class.
        dry_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}#{method_signature}
            Debug.guard_against_mocktail_accidentally_calling_mocks_if_debugging!
            HandlesDryClass.new.handle(Call.new(
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
          end
        RUBY
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
