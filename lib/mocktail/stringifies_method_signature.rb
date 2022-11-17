module Mocktail
  class StringifiesMethodSignature
    def stringify(signature)
      positional_params = positional(signature)
      dotdotdot_param = dotdotdot(signature)
      keyword_params = keyword(signature) if dotdotdot_param.nil?
      block_param = block(signature) if dotdotdot_param.nil?

      "(#{[positional_params, dotdotdot_param, keyword_params, block_param].compact.join(", ")})"
    end

    private

    def positional(signature)
      params = signature.positional_params.all.map do |name|
        if signature.positional_params.allowed.include?(name)
          "#{name} = ((__mocktail_default_args ||= {})[:#{name}] = nil)"
        elsif signature.positional_params.rest == name && name != :*
          "*#{name}"
        end
      end.compact

      params.join(", ") if params.any?
    end

    def keyword(signature)
      params = signature.keyword_params.all.map do |name|
        if signature.keyword_params.allowed.include?(name)
          "#{name}: ((__mocktail_default_args ||= {})[:#{name}] = nil)"
        elsif signature.keyword_params.rest == name && name != :**
          "**#{name}"
        end
      end.compact

      params.join(", ") if params.any?
    end

    def block(signature)
      if signature.block_param
        "&#{signature.block_param}"
      end
    end

    def dotdotdot(signature)
      if signature.positional_params.rest == :* &&
          signature.keyword_params.rest == :** &&
          signature.block_param == :&
        "..."
      end
    end

    def rest_name(params)
      if params.rest && params.rest != :* && params.rest != :**
        params.rest
      end
    end
  end
end
