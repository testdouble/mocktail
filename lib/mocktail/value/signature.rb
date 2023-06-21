# typed: true

module Mocktail
  Signature = Struct.new(
    :positional_params,
    :positional_args,
    :keyword_params,
    :keyword_args,
    :block_param,
    :block_arg,
    keyword_init: true
  )
  class Signature
    DEFAULT_REST_ARGS = "args"
    DEFAULT_REST_KWARGS = "kwargs"
    DEFAULT_BLOCK_PARAM = "blk"
  end

  Params = Struct.new(
    :all,
    :required,
    :optional,
    :rest,
    keyword_init: true
  ) do
    def initialize(**params)
      super
      self.all ||= []
      self.required ||= []
      self.optional ||= []
    end

    def allowed
      all.select { |name| required.include?(name) || optional.include?(name) }
    end

    def rest?
      !!rest
    end
  end
end
