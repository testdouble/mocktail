# typed: strict

require_relative "declares_dry_class/reconstructs_call"

module Mocktail
  class DeclaresDryClass
    extend T::Sig

    DEFAULT_ANCESTORS = T.let(T.must(Class.new(Object).ancestors[1..]), T::Array[T.any(T::Class[T.anything], Module)])

    sig { void }
    def initialize
      @raises_neato_no_method_error = T.let(RaisesNeatoNoMethodError.new, RaisesNeatoNoMethodError)
      @transforms_params = T.let(TransformsParams.new, TransformsParams)
      @stringifies_method_signature = T.let(StringifiesMethodSignature.new, StringifiesMethodSignature)
      @grabs_original_method_parameters = T.let(GrabsOriginalMethodParameters.new, GrabsOriginalMethodParameters)
    end

    sig {
      type_parameters(:T)
        .params(type: T.all(T.type_parameter(:T), T::Class[T.anything]), instance_methods: T::Array[Symbol]).returns(T.type_parameter(:T))
    }
    def declare_from_class(type, instance_methods)
      dry_class = Class.new(Object) {
        define_method :initialize do |*args, **kwargs, &blk|
        end

        [:is_a?, :kind_of?].each do |method_name|
          define_method method_name, ->(thing) {
            # Mocktails extend from Object, so share the same ancestors, plus the passed type
            [type, *DEFAULT_ANCESTORS].include?(thing)
          }
        end

        define_method :instance_of?, ->(thing) {
          type == thing
        }
      }

      add_more_methods!(dry_class, type, instance_methods)

      T.unsafe(dry_class) # This is all fake! That's the whole point—it's not a real Foo, it's just some new class that quacks like a Foo
    end

    sig {
      type_parameters(:T)
        .params(type: T.all(T.type_parameter(:T), Module), instance_methods: T::Array[Symbol]).returns(T::Class[T.type_parameter(:T)])
    }
    def declare_from_module(type, instance_methods)
      dry_class = Class.new(Object) {
        include type

        define_method :initialize do |*args, **kwargs, &blk|
        end

        [:is_a?, :kind_of?].each do |method_name|
          define_method method_name, ->(thing) {
            # Mocktails extend from Object, so share the same ancestors, plus the passed type
            [type, *DEFAULT_ANCESTORS].include?(thing)
          }
        end
      }

      add_more_methods!(dry_class, type, instance_methods)

      T.unsafe(dry_class) # Sorbet apparently can't see the dynamic include of the module and types this as T::Class[Object]
    end

    private

    # These have special implementations, but if the user defines
    # any of them on the object itself, then they'll be replaced with normal
    # mocked methods. YMMV
    sig { params(dry_class: T::Class[Object], type: T.any(T::Class[T.anything], Module), instance_methods: T::Array[Symbol]).void }
    def add_more_methods!(dry_class, type, instance_methods)
      add_stringify_methods!(dry_class, :to_s, type, instance_methods)
      add_stringify_methods!(dry_class, :inspect, type, instance_methods)
      define_method_missing_errors!(dry_class, type, instance_methods)

      define_double_methods!(dry_class, type, instance_methods)
    end

    sig { params(dry_class: T::Class[Object], type: T.any(T::Class[T.anything], Module), instance_methods: T::Array[Symbol]).void }
    def define_double_methods!(dry_class, type, instance_methods)
      instance_methods.each do |method_name|
        dry_class.undef_method(method_name) if dry_class.method_defined?(method_name)
        parameters = @grabs_original_method_parameters.grab(type.instance_method(method_name))
        signature = @transforms_params.transform(Call.new, params: parameters)
        method_signature = @stringifies_method_signature.stringify(signature)
        __mocktail_closure = {
          dry_class: dry_class,
          type: type,
          method: method_name,
          original_method: type.instance_method(method_name),
          signature: signature
        }

        dry_class.define_method method_name,
          eval(<<-RUBBY, binding, __FILE__, __LINE__ + 1) # standard:disable Security/Eval
            ->#{method_signature} do
              ::Mocktail::Debug.guard_against_mocktail_accidentally_calling_mocks_if_debugging!
              ::Mocktail::HandlesDryCall.new.handle(::Mocktail::ReconstructsCall.new.reconstruct(
                double: self,
                call_binding: __send__(:binding),
                default_args: (__send__(:binding).local_variable_defined?(:__mocktail_default_args) ? __send__(:binding).local_variable_get(:__mocktail_default_args) : {}),
                **__mocktail_closure
              ))
            end
          RUBBY
      end
    end

    sig { params(dry_class: T::Class[Object], method_name: Symbol, type: T.any(T::Class[T.anything], Module), instance_methods: T::Array[Symbol]).void }
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

    sig { params(dry_class: T::Class[Object], type: T.any(T::Class[T.anything], Module), instance_methods: T::Array[Symbol]).void }
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
