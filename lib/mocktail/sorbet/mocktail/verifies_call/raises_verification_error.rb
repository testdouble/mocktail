# typed: strict

require_relative "raises_verification_error/gathers_calls_of_method"
require_relative "../share/stringifies_method_name"
require_relative "../share/stringifies_call"

module Mocktail
  class RaisesVerificationError
    extend T::Sig

    sig { void }
    def initialize
      @gathers_calls_of_method = T.let(GathersCallsOfMethod.new, GathersCallsOfMethod)
      @stringifies_method_name = T.let(StringifiesMethodName.new, StringifiesMethodName)
      @stringifies_call = T.let(StringifiesCall.new, StringifiesCall)
    end

    sig { params(recording: Call, verifiable_calls: T::Array[Call], demo_config: DemoConfig).void }
    def raise(recording, verifiable_calls, demo_config)
      Kernel.raise VerificationError.new <<~MSG
        Expected mocktail of `#{@stringifies_method_name.stringify(recording)}' to be called like:

          #{@stringifies_call.stringify(recording)}#{[
            (" [#{demo_config.times} #{pl("time", demo_config.times)}]" unless demo_config.times.nil?),
            (" [ignoring extra args]" if demo_config.ignore_extra_args),
            (" [ignoring blocks]" if demo_config.ignore_block)
          ].compact.join(" ")}

        #{[
          describe_verifiable_times_called(demo_config, verifiable_calls.size),
          describe_other_calls(recording, verifiable_calls, demo_config)
        ].compact.join("\n\n")}
      MSG
    end

    private

    sig { params(demo_config: DemoConfig, count: Integer).returns(T.nilable(String)) }
    def describe_verifiable_times_called(demo_config, count)
      return if demo_config.times.nil?

      if count == 0
        "But it was never called this way."
      else
        "But it was actually called this way #{count} #{pl("time", count)}."
      end
    end

    sig { params(recording: Call, verifiable_calls: T::Array[Call], demo_config: DemoConfig).returns(T.nilable(String)) }
    def describe_other_calls(recording, verifiable_calls, demo_config)
      calls_of_method = @gathers_calls_of_method.gather(recording) - verifiable_calls
      if calls_of_method.size == 0
        if demo_config.times.nil?
          "But it was never called."
        end
      else
        <<~MSG
          It was called differently #{calls_of_method.size} #{pl("time", calls_of_method.size)}:

          #{calls_of_method.map { |call| "  " + @stringifies_call.stringify(call) }.join("\n\n")}
        MSG
      end
    end

    sig { params(s: String, count: T.nilable(Integer)).returns(String) }
    def pl(s, count)
      if count == 1
        s
      else
        s + "s"
      end
    end
  end
end
