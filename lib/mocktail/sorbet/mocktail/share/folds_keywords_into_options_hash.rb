# typed: strict

module Mocktail
  class FoldsKeywordsIntoOptionsHash
    extend T::Sig

    KEYWORD_PARAM_TYPES = T.let([:key, :keyreq, :keyrest, :nokey].freeze, T::Array[Symbol])

    sig { void }
    def initialize
      @grabs_original_method_parameters = T.let(GrabsOriginalMethodParameters.new, GrabsOriginalMethodParameters)
    end

    # Ruby 3 passes keywords to a method with no keyword params as a trailing
    # positional hash, but our generic (*args, **kwargs) lambdas always split
    # them out, so fold them back in to match what the real method would see
    sig { params(original_method: T.nilable(T.any(UnboundMethod, Method)), args: T::Array[T.anything], kwargs: T::Hash[Symbol, T.anything]).returns([T::Array[T.anything], T::Hash[Symbol, T.anything]]) }
    def fold(original_method, args, kwargs)
      return [args, kwargs] if kwargs.empty? || original_method.nil?
      return [args, kwargs] if @grabs_original_method_parameters.grab(original_method).any? { |type, _| KEYWORD_PARAM_TYPES.include?(type) }

      [[*args, kwargs], {}]
    end
  end
end
