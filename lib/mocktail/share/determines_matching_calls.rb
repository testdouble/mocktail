module Mocktail
  class DeterminesMatchingCalls
    def determine(real_call, demo_call)
      real_call.double == demo_call.double &&
        real_call.method == demo_call.method &&

        # Matcher implementation will replace this:
        args_match?(real_call.args, demo_call.args) &&
        kwargs_match?(real_call.kwargs, demo_call.kwargs) &&
        real_call.block == demo_call.block
    end

    private

    def args_match?(real_args, demo_args)
      real_args.size == demo_args.size &&
        real_args.zip(demo_args).all? { |real_arg, demo_arg|
          match?(real_arg, demo_arg)
        }
    end

    def kwargs_match?(real_kwargs, demo_kwargs)
      real_kwargs.size == demo_kwargs.size &&
        demo_kwargs.all? { |key, demo_val|
          real_kwargs.key?(key) && match?(real_kwargs[key], demo_val)
        }
    end

    def match?(real_arg, demo_arg)
      if demo_arg.respond_to?(:is_mocktail_matcher?) &&
          demo_arg.is_mocktail_matcher?
        demo_arg.match?(real_arg)
      else
        demo_arg == real_arg
      end
    end
  end
end
