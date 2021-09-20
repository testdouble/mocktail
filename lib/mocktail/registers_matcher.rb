module Mocktail
  class InvalidMatcherError < Error; end

  class RegistersMatcher
    def self.instance
      @registers_matcher ||= new
    end

    def register(matcher_type)
      if invalid_type?(matcher_type)
        raise InvalidMatcherError.new <<~MSG.tr("\n", " ")
          Matchers must be Ruby classes
        MSG
      elsif invalid_name?(matcher_type)
        raise InvalidMatcherError.new <<~MSG.tr("\n", " ")
          #{matcher_type.name}.matcher_name must return a valid method name
        MSG
      elsif invalid_match?(matcher_type)
        raise InvalidMatcherError.new <<~MSG.tr("\n", " ")
          #{matcher_type.name}#match? must be defined as a one-argument method
        MSG
      elsif invalid_flag?(matcher_type)
        raise InvalidMatcherError.new <<~MSG.tr("\n", " ")
          #{matcher_type.name}#is_mocktail_matcher? must be defined
        MSG
      else
        MatcherRegistry.instance.add(matcher_type)
      end
    end

    private

    def invalid_type?(matcher_type)
      !matcher_type.is_a?(Class)
    end

    def invalid_name?(matcher_type)
      return true unless matcher_type.respond_to?(:matcher_name)
      name = matcher_type.matcher_name

      !(name.is_a?(String) || name.is_a?(Symbol)) ||
        name.to_sym.inspect.start_with?(":\"")
    end

    def invalid_match?(matcher_type)
      params = matcher_type.instance_method(:match?).parameters
      params.size > 1 || ![:req, :opt].include?(params.first[0])
    rescue NameError
      true
    end

    def invalid_flag?(matcher_type)
      !matcher_type.instance_method(:is_mocktail_matcher?)
    rescue NameError
      true
    end
  end
end
