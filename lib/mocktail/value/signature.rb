module Mocktail
  class Signature < Struct.new(
    :positional_params,
    :positional_args,
    :keyword_params,
    :keyword_args,
    :block_param,
    :block_arg,
    keyword_init: true
  )
    DEFAULT_REST_ARGS = "args"
    DEFAULT_REST_KWARGS = "kwargs"
    DEFAULT_BLOCK_PARAM = "blk"
  end

  class Params < Struct.new(
    :all,
    :required,
    :optional,
    :rest,
    keyword_init: true
  )

    def initialize(**params)
      super
      self.all ||= []
      self.required ||= []
      self.optional ||= []
    end

    def allowed
      required + optional
    end

    def rest?
      !!rest
    end
  end
end
