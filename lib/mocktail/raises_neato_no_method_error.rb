# typed: strict

require_relative "share/stringifies_call"
require_relative "share/stringifies_method_name"
require_relative "share/creates_identifier"

module Mocktail
  class RaisesNeatoNoMethodError
    extend T::Sig

    sig { void }
    def initialize
      @stringifies_call = T.let(StringifiesCall.new, StringifiesCall)
      @stringifies_method_name = T.let(StringifiesMethodName.new, StringifiesMethodName)
      @creates_identifier = T.let(CreatesIdentifier.new, CreatesIdentifier)
    end

    sig { params(call: Call).void }
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

    sig { params(call: Call).returns(T.nilable(String)) }
    def params(call)
      return if (params_lists = [
        params_list(call.args),
        kwparams_list(call.kwargs),
        block_param(call.block)
      ].compact).empty?

      "(#{params_lists.join(", ")})"
    end

    sig { params(args: T::Array[T.anything]).returns(T.nilable(String)) }
    def params_list(args)
      return if args.empty?

      count_repeats(args.map { |arg|
        @creates_identifier.create(arg, default: "arg")
      }).join(", ")
    end

    sig { params(kwargs: T::Hash[Symbol, T.anything]).returns(T.nilable(String)) }
    def kwparams_list(kwargs)
      return if kwargs.empty?

      kwargs.keys.map { |key| "#{key}:" }.join(", ")
    end

    sig { params(block: T.nilable(Proc)).returns(T.nilable(String)) }
    def block_param(block)
      return if block.nil?

      "&blk"
    end

    sig { params(identifiers: T::Array[String]).returns(T::Array[String]) }
    def count_repeats(identifiers)
      identifiers.map.with_index { |id, i|
        if (preceding_matches = T.must(identifiers[0...i]).count { |other_id| id == other_id }) > 0
          "#{id}#{preceding_matches + 1}"
        else
          id
        end
      }
    end

    sig { params(call: Call).returns(T.nilable(String)) }
    def corrections(call)
      return if (corrections = DidYouMean::SpellChecker.new(dictionary: T.must(call.original_type).instance_methods).correct(T.must(call.method))).empty?

      <<~MSG

        There #{(corrections.size == 1) ? "is" : "are"} also #{corrections.size} similar method#{"s" if corrections.size != 1} on #{T.must(call.original_type).name}.

        Did you mean?
        #{corrections.map { |c| "  #{c}" }.join("\n")}
      MSG
    end
  end
end
