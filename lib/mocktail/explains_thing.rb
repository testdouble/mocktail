require_relative "share/stringifies_method_name"
require_relative "share/stringifies_call"

module Mocktail
  class ExplainsThing
    def initialize
      @stringifies_method_name = StringifiesMethodName.new
      @stringifies_call = StringifiesCall.new
    end

    def explain(thing)
      if (double = Mocktail.cabinet.double_for_instance(thing))
        double_explanation(double)
      elsif (type_replacement = TopShelf.instance.type_replacement_if_exists_for(thing))
        replaced_type_explanation(type_replacement)
      else
        no_explanation(thing)
      end
    end

    private

    def double_explanation(double)
      double_data = DoubleData.new(
        type: double.original_type,
        double: double.dry_instance,
        calls: Mocktail.cabinet.calls_for_double(double),
        stubbings: Mocktail.cabinet.stubbings_for_double(double)
      )

      DoubleExplanation.new(double_data, <<~MSG)
        This is a fake `#{double.original_type.name}' instance.

        It has these mocked methods:
        #{double.dry_methods.sort.map { |method| "  - #{method}" }.join("\n")}

        #{double.dry_methods.sort.map { |method| describe_dry_method(double_data, method) }.join("\n")}
      MSG
    end

    def replaced_type_explanation(type_replacement)
      type_replacement_data = TypeReplacementData.new(
        type: type_replacement.type,
        replaced_method_names: type_replacement.replacement_methods.map(&:name).sort,
        calls: Mocktail.cabinet.calls.select { |call|
          call.double == type_replacement.type
        },
        stubbings: Mocktail.cabinet.stubbings.select { |stubbing|
          stubbing.recording.double == type_replacement.type
        }
      )

      ReplacedTypeExplanation.new(type_replacement_data, <<~MSG)
        `#{type_replacement.type}' is a #{type_replacement.type.class.to_s.downcase} that has had its singleton methods faked.

        It has these mocked methods:
        #{type_replacement_data.replaced_method_names.map { |method| "  - #{method}" }.join("\n")}

        #{type_replacement_data.replaced_method_names.map { |method| describe_dry_method(type_replacement_data, method) }.join("\n")}
      MSG
    end

    def describe_dry_method(double_data, method)
      method_name = @stringifies_method_name.stringify(Call.new(
        original_type: double_data.type,
        singleton: double_data.type == double_data.double,
        method: method
      ))

      [
        describe_multiple_calls(
          double_data.stubbings.map(&:recording).select { |call|
            call.method == method
          },
          "`#{method_name}' stubbings",
          "`#{method_name}' has no stubbings"
        ),
        describe_multiple_calls(
          double_data.calls.select { |call|
            call.method == method
          },
          "`#{method_name}' calls",
          "`#{method_name}' has no calls"
        )
      ].join("\n")
    end

    def describe_multiple_calls(calls, nonzero_message, zero_message)
      if calls.empty?
        "#{zero_message}.\n"
      else
        <<~MSG
          #{nonzero_message}:

          #{calls.map { |call| "  " + @stringifies_call.stringify(call) }.join("\n\n")}
        MSG
      end
    end

    def no_explanation(thing)
      NoExplanation.new(thing,
        "Unfortunately, Mocktail doesn't know what this thing is: #{thing.inspect}")
    end
  end
end
