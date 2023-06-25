# typed: strict

module Mocktail
  class GrabsOriginalMethodParameters
    extend T::Sig

    # Sorbet wraps the original method in a sig wrapper, so we need to unwrap it.
    # The value returned from `owner.instance_method(method_name)` does not have
    # the real parameters values available, as they'll have been erased
    #
    # If the method isn't wrapped by Sorbet, this will return the #instance_method,
    # per usual

    def grab(method)
      return [] unless method

      if (wrapped_method = sorbet_wrapped_method(method))
        wrapped_method.parameters
      else
        method.parameters
      end
    end

    private

    def sorbet_wrapped_method(method)
      return unless defined?(::T::Private::Methods)

      T::Private::Methods.signature_for_method(method)
    end
  end
end
