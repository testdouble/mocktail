module Mocktail
  class TransformsParams
    def transform(dry_call)
      params = dry_call.original_method.parameters

      Signature.new(
        positional_params: Params.new(
          all: params.select { |type, _|
            [:req, :opt, :rest].include?(type)
          }.map { |_, name| name },
          required: params.select { |t, _| t == :req }.map { |_, n| n },
          optional: params.select { |t, _| t == :opt }.map { |_, n| n },
          rest: params.find { |type, _| type == :rest } & [1]
        ),
        positional_args: dry_call.args,

        keyword_params: Params.new(
          all: params.select { |type, _|
            [:keyreq, :key, :keyrest].include?(type)
          }.map { |_, name| name },
          required: params.select { |t, _| t == :keyreq }.map { |_, n| n },
          optional: params.select { |t, _| t == :key }.map { |_, n| n },
          rest: params.find { |type, _| type == :keyrest } & [1]
        ),
        keyword_args: dry_call.kwargs,

        block_param: params.find { |type, _| type == :block } & [1],
        block_arg: dry_call.block
      )
    end
  end
end
