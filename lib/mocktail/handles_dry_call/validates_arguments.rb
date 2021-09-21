module Mocktail
  class ValidatesArguments
    def self.disable!
      Thread.current[:mocktail_arity_validation_disabled] = true
    end

    def self.enable!
      Thread.current[:mocktail_arity_validation_disabled] = false
    end

    def self.disabled?
      Thread.current[:mocktail_arity_validation_disabled]
    end

    def self.optional(disable, &blk)
      return blk.call unless disable

      disable!
      blk.call.tap do
        enable!
      end
    end

    def validate(dry_call)
      return if self.class.disabled?

      arg_params, kwarg_params = dry_call.original_method.parameters.reject { |type, _|
        type == :block
      }.partition { |type, _|
        [:req, :opt, :rest].include?(type)
      }

      unless args_match?(arg_params, dry_call.args) &&
          kwargs_match?(kwarg_params, dry_call.kwargs)
        # TODO - replace all this with a smarter printout of expectation
        raise ArgumentError.new("wrong number of arguments")
      end
    end

    private

    def args_match?(arg_params, args)
      args.size >= arg_params.count { |type, _| type == :req } &&
        (arg_params.any? { |type, _| type == :rest } || args.size <= arg_params.size)
    end

    def kwargs_match?(kwarg_params, kwargs)
      kwarg_params.select { |type, _| type == :keyreq }.all? { |_, name| kwargs.key?(name) } &&
        (kwarg_params.any? { |type, _| type == :keyrest } || kwargs.keys.all? { |name| kwarg_params.any? { |_, key| name == key } })
    end
  end
end
