# typed: strict

require_relative "bind"

module Mocktail
  class DeterminesMatchingCalls
    extend T::Sig

    sig { params(real_call: Call, demo_call: Call, demo_config: DemoConfig).returns(T::Boolean) }
    def determine(real_call, demo_call, demo_config)
      T.cast(Bind.call(real_call.double, :==, demo_call.double), T::Boolean) &&
        real_call.method == demo_call.method &&

        # Matcher implementation will replace this:
        args_match?(real_call.args, demo_call.args, demo_config.ignore_extra_args) &&
        kwargs_match?(real_call.kwargs, demo_call.kwargs, demo_config.ignore_extra_args) &&
        blocks_match?(real_call.block, demo_call.block, demo_config.ignore_block)
    end

    private

    sig { params(real_args: T::Array[T.untyped], demo_args: T::Array[T.untyped], ignore_extra_args: T::Boolean).returns(T::Boolean) }
    def args_match?(real_args, demo_args, ignore_extra_args)
      # Guard clause for performance:
      return true if ignore_extra_args && demo_args.empty?

      (
        real_args.size == demo_args.size ||
        (ignore_extra_args && real_args.size >= demo_args.size)
      ) &&
        demo_args.each.with_index.all? { |demo_arg, i|
          match?(real_args[i], demo_arg)
        }
    end

    sig { params(real_kwargs: T::Hash[Symbol, T.untyped], demo_kwargs: T::Hash[Symbol, T.untyped], ignore_extra_args: T::Boolean).returns(T::Boolean) }
    def kwargs_match?(real_kwargs, demo_kwargs, ignore_extra_args)
      return true if ignore_extra_args && demo_kwargs.empty?

      (
        real_kwargs.size == demo_kwargs.size ||
        (ignore_extra_args && real_kwargs.size >= demo_kwargs.size)
      ) &&
        demo_kwargs.all? { |key, demo_val|
          real_kwargs.key?(key) && match?(real_kwargs[key], demo_val)
        }
    end

    sig { params(real_block: T.nilable(Proc), demo_block: T.nilable(Proc), ignore_block: T::Boolean).returns(T::Boolean) }
    def blocks_match?(real_block, demo_block, ignore_block)
      !!(ignore_block ||
        (real_block.nil? && demo_block.nil?) ||
        (
          real_block && demo_block &&
          (
            demo_block == real_block ||
            demo_block.call(real_block)
          )
        ))
    end

    sig { params(real_arg: T.untyped, demo_arg: T.untyped).returns(T::Boolean) }
    def match?(real_arg, demo_arg)
      if Bind.call(demo_arg, :respond_to?, :is_mocktail_matcher?) &&
          demo_arg.is_mocktail_matcher?
        demo_arg.match?(real_arg)
      else
        Bind.call(demo_arg, :==, real_arg)
      end
    end
  end
end
