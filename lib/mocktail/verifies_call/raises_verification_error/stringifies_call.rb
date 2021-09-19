module Mocktail
  class StringifiesCall
    def stringify(call)
      "#{call.method}#{args_to_s(call)}#{blockify(call.block)}"
    end

    private

    def args_to_s(call)
      unless (args_lists = [
        argify(call.args),
        kwargify(call.kwargs),
        lambdafy(call.block)
      ].compact).empty?
        "(#{args_lists.join(", ")})"
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

    def blockify(block)
      return unless block && !block.lambda?
      " { Proc at #{source_locationify(block)} }"
    end

    def source_locationify(block)
      "#{strip_pwd(block.source_location[0])}:#{block.source_location[1]}"
    end

    def strip_pwd(path)
      path.gsub(Dir.pwd + File::SEPARATOR, "")
    end
  end
end
