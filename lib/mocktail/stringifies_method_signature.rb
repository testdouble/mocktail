# typed: false

module Mocktail
  class StringifiesMethodSignature
    def stringify(signature)
      positional_params = positional(signature)
      keyword_params = keyword(signature)
      block_param = block(signature)

      "(#{[positional_params, keyword_params, block_param].compact.join(", ")})"
    end

    private

    def positional(signature)
      params = signature.positional_params.all.map do |name|
        if signature.positional_params.allowed.include?(name)
          "#{name} = ((__mocktail_default_args ||= {})[:#{name}] = nil)"
        elsif signature.positional_params.rest == name
          "*#{(name == :*) ? Signature::DEFAULT_REST_ARGS : name}"
        end
      end.compact

      params.join(", ") if params.any?
    end

    def keyword(signature)
      params = signature.keyword_params.all.map do |name|
        if signature.keyword_params.allowed.include?(name)
          "#{name}: ((__mocktail_default_args ||= {})[:#{name}] = nil)"
        elsif signature.keyword_params.rest == name
          "**#{(name == :**) ? Signature::DEFAULT_REST_KWARGS : name}"
        end
      end.compact

      params.join(", ") if params.any?
    end

    def block(signature)
      if signature.block_param && signature.block_param != :&
        "&#{signature.block_param}"
      else
        "&#{Signature::DEFAULT_BLOCK_PARAM}"
      end
    end
  end
end
