# typed: strict

require_relative "simulates_argument_error/transforms_params"
require_relative "simulates_argument_error/reconciles_args_with_params"
require_relative "simulates_argument_error/recreates_message"
require_relative "share/cleans_backtrace"
require_relative "share/stringifies_call"

module Mocktail
  class SimulatesArgumentError
    extend T::Sig

    sig { void }
    def initialize
      @transforms_params = T.let(TransformsParams.new, TransformsParams)
      @reconciles_args_with_params = T.let(ReconcilesArgsWithParams.new, ReconcilesArgsWithParams)
      @recreates_message = T.let(RecreatesMessage.new, RecreatesMessage)
      @cleans_backtrace = T.let(CleansBacktrace.new, CleansBacktrace)
      @stringifies_call = T.let(StringifiesCall.new, StringifiesCall)
    end

    sig { params(dry_call: Call).returns(T.nilable(ArgumentError)) }
    def simulate(dry_call)
      signature = @transforms_params.transform(dry_call)

      unless @reconciles_args_with_params.reconcile(signature)
        @cleans_backtrace.clean(
          ArgumentError.new([
            @recreates_message.recreate(signature),
            "[Mocktail call: `#{@stringifies_call.stringify(dry_call)}']"
          ].join(" "))
        )
      end
    end
  end
end
