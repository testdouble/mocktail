# typed: strict

module Mocktail
  class StringifiesCall
    extend T::Sig

    sig { params(call: Call, anonymous_blocks: T::Boolean, always_parens: T::Boolean).returns(String) }
    def stringify(call, anonymous_blocks: false, always_parens: false)
      "#{call.method}#{args_to_s(call, parens: always_parens)}#{blockify(call.block, anonymous: anonymous_blocks)}"
    end

    sig { params(calls: T::Array[Call], nonzero_message: String, zero_message: String, anonymous_blocks: T::Boolean, always_parens: T::Boolean).returns(String) }
    def stringify_multiple(calls, nonzero_message:, zero_message:,
      anonymous_blocks: false, always_parens: false)

      if calls.empty?
        "#{zero_message}.\n"
      else
        <<~MSG
          #{nonzero_message}:

          #{calls.map { |call| "  " + stringify(call) }.join("\n\n")}
        MSG
      end
    end

    private

    sig { params(call: Call, parens: T::Boolean).returns(T.nilable(String)) }
    def args_to_s(call, parens: true)
      args_lists = [
        argify(call.args),
        kwargify(call.kwargs),
        lambdafy(call.block)
      ].compact

      if !args_lists.empty?
        "(#{args_lists.join(", ")})"
      elsif parens
        "()"
      else
        ""
      end
    end

    sig { params(args: T::Array[Object]).returns(T.nilable(String)) }
    def argify(args)
      return unless !args.empty?
      args.map(&:inspect).join(", ")
    end

    sig { params(kwargs: T::Hash[Symbol, Object]).returns(T.nilable(String)) }
    def kwargify(kwargs)
      return unless !kwargs.empty?
      kwargs.map { |key, val| "#{key}: #{val.inspect}" }.join(", ")
    end

    sig { params(block: T.nilable(Proc)).returns(T.nilable(String)) }
    def lambdafy(block)
      return unless block&.lambda?
      "&lambda[#{source_locationify(block)}]"
    end

    sig { params(block: T.nilable(Proc), anonymous: T::Boolean).returns(T.nilable(String)) }
    def blockify(block, anonymous:)
      return unless block && !block.lambda?

      if anonymous
        " {…}"
      else
        " { Proc at #{source_locationify(block)} }"
      end
    end

    sig { params(block: Proc).returns(String) }
    def source_locationify(block)
      "#{strip_pwd(block.source_location[0])}:#{block.source_location[1]}"
    end

    sig { params(path: String).returns(String) }
    def strip_pwd(path)
      path.gsub(Dir.pwd + File::SEPARATOR, "")
    end
  end
end
