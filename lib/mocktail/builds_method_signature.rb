module Mocktail
  class BuildsMethodSignature
    def build(signature)
      @signature = signature
      "(#{[positional, keyword, block, dotdotdot].reject(&:empty?).join(", ")})"
    end

    def dotdotdot
      @dotdotdot ||= if @signature.positional_params.rest == :* &&
          @signature.keyword_params.rest == :** &&
          @signature.block_param == :&
        "..."
      else
        ""
      end
    end

    def positional
      @signature.positional_params.all.map do |name|
        if @signature.positional_params.required.include?(name)
          name.to_s
        elsif @signature.positional_params.optional.include?(name)
          "#{name} = nil"
        elsif @signature.positional_params.rest == name && name != :*
          "*#{name}"
        end
      end.compact.join(", ")
    end

    def keyword
      if dotdotdot.empty?
        @signature.keyword_params.all.map do |name|
          if @signature.keyword_params.required.include?(name)
            "#{name}:"
          elsif @signature.keyword_params.optional.include?(name)
            "#{name}: nil"
          elsif @signature.keyword_params.rest == name && name != :**
            "**#{name}" end
        end.join(", ")
      else
        ""
      end
    end

    def block
      if dotdotdot.empty? && @signature.block_param
        "&block"
      else
        ""
      end
    end
  end
end
