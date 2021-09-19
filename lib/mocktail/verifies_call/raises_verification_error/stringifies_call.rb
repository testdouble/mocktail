module Mocktail
  class StringifiesCall
    def stringify(call)
      "#{call.method}#{args_to_s(call)}#{blockify(call.blk)}"
    end

    private

    def args_to_s(call)
      unless (args_lists = [
        argify(call.args),
        kwargify(call.kwargs),
        lambdafy(call.blk)
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

    def lambdafy(blk)
      return unless blk&.lambda?
      "&lambda[#{source_locationify(blk)}]"
    end

    def blockify(blk)
      return unless blk && !blk.lambda?
      " { Proc at #{source_locationify(blk)} }"
    end

    def source_locationify(blk)
      "#{strip_pwd(blk.source_location[0])}:#{blk.source_location[1]}"
    end

    def strip_pwd(path)
      path.gsub(Dir.pwd + File::SEPARATOR, "")
    end
  end
end
