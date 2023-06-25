# typed: strict

module Mocktail
  class MatcherPresentation
    extend T::Sig

    sig { params(name: Symbol, include_private: T::Boolean).returns(T::Boolean) }
    def respond_to_missing?(name, include_private = false)
      !!MatcherRegistry.instance.get(name) || super
    end

    sig { params(name: Symbol, args: T.anything, kwargs: T.anything, blk: T.nilable(Proc)).returns(T.anything) }
    def method_missing(name, *args, **kwargs, &blk)
      if (matcher = MatcherRegistry.instance.get(name))
        T.unsafe(matcher).new(*args, **kwargs, &blk)
      else
        super
      end
    end
  end
end
