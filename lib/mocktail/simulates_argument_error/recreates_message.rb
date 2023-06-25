# typed: strict

module Mocktail
  class RecreatesMessage
    extend T::Sig

    def recreate(signature)
      req_args = signature.positional_params.required.size
      allowed_args = signature.positional_params.allowed.size
      rest_args = signature.positional_params.rest?
      req_kwargs = signature.keyword_params.required

      if signature.positional_args.size < req_args || (!rest_args && signature.positional_args.size > allowed_args)
        expected_desc = if rest_args
          "#{req_args}+"
        elsif allowed_args != req_args
          "#{req_args}..#{allowed_args}"
        else
          req_args.to_s
        end

        "wrong number of arguments (given #{signature.positional_args.size}, expected #{expected_desc}#{"; required keyword#{"s" if req_kwargs.size > 1}: #{req_kwargs.join(", ")}" unless req_kwargs.empty?})"

      elsif !(missing_kwargs = req_kwargs.reject { |name| signature.keyword_args.key?(name) }).empty?
        "missing keyword#{"s" if missing_kwargs.size > 1}: #{missing_kwargs.map { |name| name.inspect }.join(", ")}"
      elsif !(unknown_kwargs = signature.keyword_args.keys.reject { |name| signature.keyword_params.all.include?(name) }).empty?
        "unknown keyword#{"s" if unknown_kwargs.size > 1}: #{unknown_kwargs.map { |name| name.inspect }.join(", ")}"
      else
        "unknown cause (this is probably a bug in Mocktail)"
      end
    end
  end
end
