# typed: true
require_relative "simulates_argument_error/transforms_params"
require_relative "simulates_argument_error/reconciles_args_with_params"
require_relative "simulates_argument_error/recreates_message"
require_relative "share/cleans_backtrace"
require_relative "share/stringifies_call"

module Mocktail
  class SimulatesArgumentError
    def initialize
      @transforms_params = TransformsParams.new
      @reconciles_args_with_params = ReconcilesArgsWithParams.new
      @recreates_message = RecreatesMessage.new
      @cleans_backtrace = CleansBacktrace.new
      @stringifies_call = StringifiesCall.new
    end

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
