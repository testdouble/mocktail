module Mocktail
  class SimulatesArgumentError
    def simulate(arg_params, args, kwarg_params, kwargs)
      req_args = arg_params.count { |type, _| type == :req }
      opt_args = arg_params.count { |type, _| type == :opt }
      rest_args = arg_params.any? { |type, _| type == :rest }
      req_kwargs = kwarg_params.select { |type, _| type == :keyreq }

      allowed_args = req_args + opt_args
      msg = if args.size < req_args || (!rest_args && args.size > allowed_args)
        expected_desc = if rest_args
          "#{req_args}+"
        elsif allowed_args != req_args
          "#{req_args}..#{allowed_args}"
        else
          req_args.to_s
        end

        "wrong number of arguments (given #{args.size}, expected #{expected_desc}#{"; required keyword#{"s" if req_kwargs.size > 1}: #{req_kwargs.map { |_, name| name }.join(", ")}" unless req_kwargs.empty?})"

      elsif !(missing_kwargs = req_kwargs.reject { |_, name| kwargs.key?(name) }).empty?
        "missing keyword#{"s" if missing_kwargs.size > 1}: #{missing_kwargs.map { |_, name| name.inspect }.join(", ")}"
      end

      ArgumentError.new(msg)
    end
  end
end
