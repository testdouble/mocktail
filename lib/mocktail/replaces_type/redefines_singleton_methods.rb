# typed: strict

module Mocktail
  class RedefinesSingletonMethods
    extend T::Sig

    sig { void }
    def initialize
      @handles_dry_call = T.let(HandlesDryCall.new, HandlesDryCall)
    end

    sig { params(type: T.any(T::Class[T.anything], Module)).void }
    def redefine(type)
      type_replacement = TopShelf.instance.type_replacement_for(type)
      return unless type_replacement.replacement_methods.nil?

      type_replacement.original_methods = type.singleton_methods.map { |name|
        type.method(name)
      }.reject { |method| sorbet_method_hook?(method) } - [type_replacement.replacement_new]

      declare_singleton_method_missing_errors!(type)
      handles_dry_call = @handles_dry_call
      type_replacement.replacement_methods = type_replacement.original_methods&.map { |original_method|
        type.singleton_class.send(:undef_method, original_method.name)
        type.define_singleton_method original_method.name, ->(*args, **kwargs, &block) {
          if TopShelf.instance.singleton_methods_replaced?(type)
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

    sig { params(type: T.any(T::Class[T.anything], Module)).void }
    def declare_singleton_method_missing_errors!(type)
      return if type.singleton_methods.include?(:method_missing)

      raises_neato_no_method_error = RaisesNeatoNoMethodError.new
      type.define_singleton_method :method_missing,
        ->(name, *args, **kwargs, &block) {
          raises_neato_no_method_error.call(
            Call.new(
              singleton: true,
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

    private

    sig { params(method: Method).returns(T::Boolean) }
    def sorbet_method_hook?(method)
      method.owner == T::Private::Methods::SingletonMethodHooks
    end
  end
end
