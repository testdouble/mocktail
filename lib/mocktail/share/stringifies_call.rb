# typed: false

module Mocktail
  class StringifiesCall
    def stringify(call, anonymous_blocks: false, always_parens: false)
      "#{call.method}#{args_to_s(call, parens: always_parens)}#{blockify(call.block, anonymous: anonymous_blocks)}"
    end

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
      end
    end

    def argify(args)
      return unless args && !args.empty?
      args.map(&:inspect).join(", ")
    end

    def kwargify(kwargs)
      return unless kwargs && !kwargs.empty?
      kwargs.map { |key, val| "#{key}: #{val.inspect}" }.join(", ")
    end

    def lambdafy(block)
      return unless block&.lambda?
      "&lambda[#{source_locationify(block)}]"
    end

    def blockify(block, anonymous:)
      return unless block && !block.lambda?

      if anonymous
        " {…}"
      else
        " { Proc at #{source_locationify(block)} }"
      end
    end

    def source_locationify(block)
      "#{strip_pwd(block.source_location[0])}:#{block.source_location[1]}"
    end

    def strip_pwd(path)
      path.gsub(Dir.pwd + File::SEPARATOR, "")
    end
  end
end
