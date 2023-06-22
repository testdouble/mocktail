# typed: strict

module Mocktail
  class RecordsDemonstration
    extend T::Sig

    sig {
      type_parameters(:T)
        .params(
          demonstration: T.proc.params(matchers: Mocktail::MatcherPresentation).returns(T.type_parameter(:T)),
          demo_config: DemoConfig
        ).returns(Call)
    }
    def record(demonstration, demo_config)
      cabinet = Mocktail.cabinet
      prior_call_count = Mocktail.cabinet.calls.dup.size

      begin
        cabinet.demonstration_in_progress = true
        ValidatesArguments.optional(demo_config.ignore_arity) do
          demonstration.call(Mocktail.matchers)
        end
      ensure
        cabinet.demonstration_in_progress = false
      end

      if prior_call_count + 1 == cabinet.calls.size
        cabinet.calls.pop
      elsif prior_call_count == cabinet.calls.size
        raise MissingDemonstrationError.new <<~MSG.tr("\n", " ")
          `stubs` & `verify` expect an invocation of a mocked method by a passed
          block, but no invocation occurred.
        MSG
      else
        raise AmbiguousDemonstrationError.new <<~MSG.tr("\n", " ")
          `stubs` & `verify` expect exactly one invocation of a mocked method,
          but #{cabinet.calls.size - prior_call_count} were detected. As a
          result, Mocktail doesn't know which invocation to stub or verify.
        MSG
      end
    end
  end
end
