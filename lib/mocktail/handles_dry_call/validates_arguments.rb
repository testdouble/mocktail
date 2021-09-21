module Mocktail
  class ValidatesArguments
    def validate(dry_call)
      original_method = if dry_call.singleton
        TopShelf.instance.type_replacement_for(dry_call.original_type).original_methods[dry_call.method]
        dry_call.original_type.method(dry_call.method)
      else
        dry_call.original_type.instance_method(dry_call.method)
      end
      arg_params, kwarg_params = original_method.parameters.reject { |type, _|
        type == :block
      }.partition { |type, _|
        type == :req || type == :opt
      }

      unless args_match?(arg_params, dry_call.args) &&
          kwargs_match?(kwarg_params, dry_call.kwargs)

        if dry_call.singleton
          original_method.call(*dry_call.args, **dry_call.kwargs)
        else
          original_method.bind_call(dry_call.double, *dry_call.args, **dry_call.kwargs)
        end
        raise UnexpectedError.new <<~MSG
          Expected an ArgumentError but none was raised. If you're seeing this,
          please file an issue with reproduction steps [ID #1]:

          https://github.com/testdouble/mocktail/issues/new
        MSG
      end
    end

    private

    def args_match?(arg_params, args)
      args.size >= arg_params.count { |type, _| type == :req } &&
        args.size <= arg_params.size
    end

    def kwargs_match?(kwarg_params, kwargs)
      kwarg_params.select { |type, _| type == :keyreq }.all? { |_, name| kwargs.key?(name) } &&
        kwargs.keys.all? { |name| kwarg_params.any? { |_, key| name == key } }
    end
  end
end
