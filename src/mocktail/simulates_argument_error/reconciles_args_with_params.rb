# typed: strict

module Mocktail
  class ReconcilesArgsWithParams
    extend T::Sig

    sig { params(signature: Signature).returns(T::Boolean) }
    def reconcile(signature)
      args_match?(signature.positional_params, signature.positional_args) &&
        kwargs_match?(signature.keyword_params, signature.keyword_args)
    end

    private

    sig { params(arg_params: Params, args: T::Array[T.untyped]).returns(T::Boolean) }
    def args_match?(arg_params, args)
      args.size >= arg_params.required.size &&
        (arg_params.rest? || args.size <= arg_params.allowed.size)
    end

    sig { params(kwarg_params: Params, kwargs: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
    def kwargs_match?(kwarg_params, kwargs)
      kwarg_params.required.all? { |name| kwargs.key?(name) } &&
        (kwarg_params.rest? || kwargs.keys.all? { |name| kwarg_params.allowed.include?(name) })
    end
  end
end
