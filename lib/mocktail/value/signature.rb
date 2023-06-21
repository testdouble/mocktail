# typed: strict

module Mocktail
  class Params < T::Struct
    extend T::Sig

    prop :all, T::Array[Symbol], default: []
    prop :required, T::Array[Symbol], default: []
    prop :optional, T::Array[Symbol], default: []
    prop :rest, T.nilable(Symbol)

    sig { returns(T::Array[Symbol]) }
    def allowed
      all.select { |name| required.include?(name) || optional.include?(name) }
    end

    sig { returns(T::Boolean) }
    def rest?
      !!rest
    end
  end

  class Signature < T::Struct
    const :positional_params, Params
    const :positional_args, T::Array[T.untyped]
    const :keyword_params, Params
    const :keyword_args, T::Hash[Symbol, T.untyped]
    const :block_param, T.nilable(Symbol)
    const :block_arg, T.untyped, default: nil # Should be a T.nilable(T.proc), but variadic params aren't supported yet

    DEFAULT_REST_ARGS = "args"
    DEFAULT_REST_KWARGS = "kwargs"
    DEFAULT_BLOCK_PARAM = "blk"
  end
end
