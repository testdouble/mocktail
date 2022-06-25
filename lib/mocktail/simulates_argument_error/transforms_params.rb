require_relative "../share/compares_safely"

module Mocktail
  class TransformsParams
    def initialize
      @compares_safely = ComparesSafely.new
    end

    def transform(dry_call)
      params = dry_call.original_method.parameters

      Signature.new(
        positional_params: Params.new(
          all: params.select { |t, _|
            [:req, :opt, :rest].any? { |param_type| @compares_safely.compare(t, param_type) }
          }.map { |_, name| name },
          required: params.select { |t, _| @compares_safely.compare(t, :req) }.map { |_, n| n },
          optional: params.select { |t, _| @compares_safely.compare(t, :opt) }.map { |_, n| n },
          rest: params.find { |t, _| @compares_safely.compare(t, :rest) } & [1]
        ),
        positional_args: dry_call.args,

        keyword_params: Params.new(
          all: params.select { |type, _|
            [:keyreq, :key, :keyrest].include?(type)
          }.map { |_, name| name },
          required: params.select { |t, _| @compares_safely.compare(t, :keyreq) }.map { |_, n| n },
          optional: params.select { |t, _| @compares_safely.compare(t, :key) }.map { |_, n| n },
          rest: params.find { |t, _| @compares_safely.compare(t, :keyrest) } & [1]
        ),
        keyword_args: dry_call.kwargs,

        block_param: params.find { |t, _| @compares_safely.compare(t, :block) } & [1],
        block_arg: dry_call.block
      )
    end
  end
end
