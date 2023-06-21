# typed: true

require_relative "../share/bind"

module Mocktail
  class TransformsParams
    def initialize
      @grabs_original_method_parameters = GrabsOriginalMethodParameters.new
    end

    def transform(dry_call, params: nil)
      params ||= @grabs_original_method_parameters.grab(dry_call.original_method)
      params = name_unnamed_params(params)

      Signature.new(
        positional_params: Params.new(
          all: params.select { |t, _|
            [:req, :opt, :rest].any? { |param_type| Bind.call(t, :==, param_type) }
          }.map { |_, name| name },
          required: params.select { |t, _| Bind.call(t, :==, :req) }.map { |_, n| n },
          optional: params.select { |t, _| Bind.call(t, :==, :opt) }.map { |_, n| n },
          rest: params.find { |t, _| Bind.call(t, :==, :rest) }&.last
        ),
        positional_args: dry_call.args,

        keyword_params: Params.new(
          all: params.select { |type, _|
            [:keyreq, :key, :keyrest].include?(type)
          }.map { |_, name| name },
          required: params.select { |t, _| Bind.call(t, :==, :keyreq) }.map { |_, n| n },
          optional: params.select { |t, _| Bind.call(t, :==, :key) }.map { |_, n| n },
          rest: params.find { |t, _| Bind.call(t, :==, :keyrest) }&.last
        ),
        keyword_args: dry_call.kwargs,

        block_param: params.find { |t, _| Bind.call(t, :==, :block) }&.last,
        block_arg: dry_call.block
      )
    end

    private

    def name_unnamed_params(params)
      params.map.with_index { |param, i|
        if param.size == 1
          param + ["unnamed_arg_#{i + 1}"]
        else
          param
        end
      }
    end
  end
end
