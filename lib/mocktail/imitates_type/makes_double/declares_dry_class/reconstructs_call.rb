module Mocktail
  class ReconstructsCall
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

    def args_for(signature, call_binding, default_args)
      arg_names, rest_name = non_default_args(signature.positional_params, default_args)

      arg_values = arg_names.map { |p| call_binding.local_variable_get(p) }
      rest_value = call_binding.local_variable_get(rest_name) if rest_name

      arg_values + (rest_value || [])
    end

    def kwargs_for(signature, call_binding, default_args)
      kwarg_names, kwrest_name = non_default_args(signature.keyword_params, default_args)

      kwarg_values = kwarg_names.to_h { |p| [p, call_binding.local_variable_get(p)] }
      kwrest_value = call_binding.local_variable_get(kwrest_name) if kwrest_name

      kwarg_values.merge(kwrest_value || {})
    end

    def non_default_args(params, default_args)
      named_args = params.allowed
        .reject { |p| default_args&.key?(p) }
      rest_arg = if params.rest && !default_args&.key?(params.rest)
        params.rest
      end

      [named_args, rest_arg]
    end
  end
end
