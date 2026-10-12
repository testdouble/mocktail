module Mocktail
  class FoldsKeywordsIntoOptionsHash
    extend T::Sig

    KEYWORD_PARAM_TYPES = [:key, :keyreq, :keyrest, :nokey].freeze

    def initialize
      @grabs_original_method_parameters = GrabsOriginalMethodParameters.new
    end

    # Ruby 3 passes keywords to a method with no keyword params as a trailing
    # positional hash, but our generic (*args, **kwargs) lambdas always split
    # them out, so fold them back in to match what the real method would see

    def fold(original_method, args, kwargs)
      return [args, kwargs] if kwargs.empty? || original_method.nil?
      return [args, kwargs] if @grabs_original_method_parameters.grab(original_method).any? { |type, _| KEYWORD_PARAM_TYPES.include?(type) }

      [[*args, kwargs], {}]
    end
  end
end
