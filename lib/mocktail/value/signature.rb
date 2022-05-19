# typed: false
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
      required + optional
    end

    def rest?
      !!rest
    end
  end
end
