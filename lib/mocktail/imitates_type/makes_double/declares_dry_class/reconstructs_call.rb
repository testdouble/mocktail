# typed: strict

module Mocktail
  class ReconstructsCall
    extend T::Sig

    sig {
      params(
        double: T.anything,
        call_binding: Binding,
        default_args: T.nilable(T::Hash[Symbol, T.untyped]),
        dry_class: T::Class[Object],
        type: T.any(Module, T::Class[T.anything]),
        method: Symbol,
        original_method: T.any(UnboundMethod, Method),
        signature: Signature
      ).returns(Call)
    }
    def reconstruct(double:, call_binding:, default_args:, dry_class:, type:, method:, original_method:, signature:)
      Call.new(
        singleton: false,
        double: double,
        original_type: type,
        dry_type: dry_class,
        method: method,
        original_method: original_method,
        args: args_for(signature, call_binding, default_args),
        kwargs: kwargs_for(signature, call_binding, default_args),
        block: call_binding.local_variable_get(signature.block_param || ::Mocktail::Signature::DEFAULT_BLOCK_PARAM)
      )
    end

    private

    sig {
      params(signature: Signature, call_binding: Binding, default_args: T.nilable(T::Hash[Symbol, T.untyped]))
        .returns(T::Array[T.untyped])
    }
    def args_for(signature, call_binding, default_args)
      arg_names, rest_name = non_default_args(signature.positional_params, default_args)

      arg_values = arg_names.map { |p| call_binding.local_variable_get(p) }
      rest_value = call_binding.local_variable_get(rest_name) if rest_name

      arg_values + (rest_value || [])
    end

    sig {
      params(signature: Signature, call_binding: Binding, default_args: T.nilable(T::Hash[Symbol, T.untyped]))
        .returns(T::Hash[Symbol, T.untyped])
    }
    def kwargs_for(signature, call_binding, default_args)
      kwarg_names, kwrest_name = non_default_args(signature.keyword_params, default_args)

      kwarg_values = kwarg_names.to_h { |p| [p, call_binding.local_variable_get(p)] }
      kwrest_value = call_binding.local_variable_get(kwrest_name) if kwrest_name

      kwarg_values.merge(kwrest_value || {})
    end

    sig { params(params: Params, default_args: T.nilable(T::Hash[Symbol, T.untyped])).returns([T::Array[Symbol], T.nilable(Symbol)]) }
    def non_default_args(params, default_args)
      named_args = params.allowed
        .reject { |p| default_args&.key?(p) }
      rest_param = params.rest
      rest_arg = if rest_param && !default_args&.key?(rest_param)
        params.rest
      end

      [named_args, rest_arg]
    end
  end
end
