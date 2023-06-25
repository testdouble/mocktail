# typed: strict

module Mocktail
  class RunsSorbetSigBlocksBeforeReplacement
    extend T::Sig

    # This is necessary because when Sorbet runs a sig block of a singleton
    # method, it has the net effect of unwrapping/redefining the method. If
    # we try to use Mocktail.replace(Foo) and Foo.bar has a Sorbet sig block,
    # then we'll end up with three "versions" of the same method and no way
    # to keep straight which one == which:
    #
    #  A - Foo.bar, as defined in the original class
    #  B - Foo.bar, as redefined by RedefinesSingletonMethods
    #  C - Foo.bar, as wrapped by sorbet-runtime
    #
    # Initially, Foo.method(:bar) would == C, but after the type
    # replacement, it would == B (with a reference back to C as the original),
    # but after while handling a single dry call, our invocation of
    # GrabsOriginalMethodParameters.grab(Foo.method(:bar)) would invoke the
    # Sorbet `sig` block, which has the net effect of redefining the method back
    # to A.
    #
    # It's very fun and confusing and a great time.
    sig { params(type: T.any(T::Class[T.anything], Module)).void }
    def run(type)
      return unless defined?(T::Private::Methods)

      type.singleton_methods.each do |method_name|
        method = type.method(method_name)

        # Again: calling this for the side effect of running the sig block
        #
        # https://github.com/sorbet/sorbet/blob/master/gems/sorbet-runtime/lib/types/private/methods/_methods.rb#L111
        T::Private::Methods.signature_for_method(method)
      end
    end
  end
end
