# typed: strict

module Mocktail
  class Params < T::Struct
    extend T::Sig

    prop :all, default: []
    prop :required, default: []
    prop :optional, default: []
    prop :rest

    def allowed
      all.select { |name| required.include?(name) || optional.include?(name) }
    end

    def rest?
      !!rest
    end
  end

  class Signature < T::Struct
    const :positional_params
    const :positional_args
    const :keyword_params
    const :keyword_args
    const :block_param
    const :block_arg, default: nil

    DEFAULT_REST_ARGS = "args"
    DEFAULT_REST_KWARGS = "kwargs"
    DEFAULT_BLOCK_PARAM = "blk"
  end
end
