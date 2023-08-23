module Mocktail
  class MatcherPresentation
    extend T::Sig

    def respond_to_missing?(name, include_private = false)
      !!MatcherRegistry.instance.get(name) || super
    end

    def method_missing(name, *args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      if (matcher = MatcherRegistry.instance.get(name))
        matcher.new(*args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      else
        super
      end
    end
  end
end
