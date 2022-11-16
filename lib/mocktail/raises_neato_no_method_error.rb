require_relative "share/stringifies_call"
require_relative "share/stringifies_method_name"
require_relative "share/creates_identifier"

module Mocktail
  class RaisesNeatoNoMethodError
    def initialize
      @stringifies_call = StringifiesCall.new
      @stringifies_method_name = StringifiesMethodName.new
      @creates_identifier = CreatesIdentifier.new
    end

    def call(call)
      raise NoMethodError, <<~MSG, caller[1..]
        No method `#{@stringifies_method_name.stringify(call)}' exists for call:

          #{@stringifies_call.stringify(call, anonymous_blocks: true, always_parens: true)}

        Need to define the method? Here's a sample definition:

          def #{"self." if call.singleton}#{call.method}#{params(call)}
          end
        #{corrections(call)}
      MSG
    end

    private

    def params(call)
      return if (params_lists = [
        params_list(call.args),
        kwparams_list(call.kwargs),
        block_param(call.block)
      ].compact).empty?

      "(#{params_lists.join(", ")})"
    end

    def params_list(args)
      return if args.empty?

      count_repeats(args.map { |arg|
        @creates_identifier.create(arg, default: "arg")
      }).join(", ")
    end

    def kwparams_list(kwargs)
      return if kwargs.empty?

      kwargs.keys.map { |key| "#{key}:" }.join(", ")
    end

    def block_param(block)
      return if block.nil?

      "&blk"
    end

    def count_repeats(identifiers)
      identifiers.map.with_index { |id, i|
        if (preceding_matches = identifiers[0...i].count { |other_id| id == other_id }) > 0
          "#{id}#{preceding_matches + 1}"
        else
          id
        end
      }
    end

    def corrections(call)
      return if (corrections = DidYouMean::SpellChecker.new(dictionary: call.original_type.instance_methods).correct(call.method)).empty?

      <<~MSG

        There #{(corrections.size == 1) ? "is" : "are"} also #{corrections.size} similar method#{"s" if corrections.size != 1} on #{call.original_type.name}.

        Did you mean?
        #{corrections.map { |c| "  #{c}" }.join("\n")}
      MSG
    end
  end
end
