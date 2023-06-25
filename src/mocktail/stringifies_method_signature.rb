# typed: strict

module Mocktail
  class StringifiesMethodSignature
    extend T::Sig

    sig { params(signature: Signature).returns(String) }
    def stringify(signature)
      positional_params = positional(signature)
      keyword_params = keyword(signature)
      block_param = block(signature)

      "(#{[positional_params, keyword_params, block_param].compact.join(", ")})"
    end

    private

    sig { params(signature: Signature).returns(T.nilable(String)) }
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

    sig { params(signature: Signature).returns(T.nilable(String)) }
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

    sig { params(signature: Signature).returns(String) }
    def block(signature)
      if signature.block_param && signature.block_param != :&
        "&#{signature.block_param}"
      else
        "&#{Signature::DEFAULT_BLOCK_PARAM}"
      end
    end
  end
end
