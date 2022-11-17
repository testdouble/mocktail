module Mocktail
  class ReconstructsCall
    def reconstruct(double:, default_args:, call_binding:, dry_class:, type:, method:, original_method:, signature:)
      Call.new(
        singleton: false,
        double: double,
        original_type: type,
        dry_type: dry_class,
        method: method,
        original_method: original_method,
        args: signature.positional_params.allowed.reject { |p| default_args&.key?(p) }.map { |p| call_binding.local_variable_get(p) } +
          ((call_binding.local_variable_get(signature.positional_params.rest) if signature.positional_params.rest && !default_args&.key?(signature.positional_params.rest)) || []),
        kwargs: signature.keyword_params.allowed.reject { |p| default_args&.key?(p) }.to_h { |p| [p, call_binding.local_variable_get(p)] }.merge(
          (call_binding.local_variable_get(signature.keyword_params.rest) if signature.keyword_params.rest && !default_args&.key?(signature.keyword_params.rest)) || {}
        ),
        block: call_binding.local_variable_get(signature.block_param || ::Mocktail::Signature::DEFAULT_BLOCK_PARAM)
      )
    end
  end
end
