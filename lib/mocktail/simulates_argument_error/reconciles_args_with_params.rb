# typed: true
module Mocktail
  class ReconcilesArgsWithParams
    def reconcile(signature)
      args_match?(signature.positional_params, signature.positional_args) &&
        kwargs_match?(signature.keyword_params, signature.keyword_args)
    end

    private

    def args_match?(arg_params, args)
      args.size >= arg_params.required.size &&
        (arg_params.rest? || args.size <= arg_params.allowed.size)
    end

    def kwargs_match?(kwarg_params, kwargs)
      kwarg_params.required.all? { |name| kwargs.key?(name) } &&
        (kwarg_params.rest? || kwargs.keys.all? { |name| kwarg_params.allowed.include?(name) })
    end
  end
end
