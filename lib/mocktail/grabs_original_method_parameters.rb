module Mocktail
  class GrabsOriginalMethodParameters
    # Sorbet wraps the original method in a sig wrapper, so we need to unwrap it.
    # The value returned from `owner.instance_method(method_name)` does not have
    # the real parameters values available, as they'll have been erased
    #
    # If the method isn't wrapped by Sorbet, this will return the #instance_method,
    # per usual
    def grab(owner, method_name)
      return owner.instance_method(method_name) unless defined?(::T::Private::Methods)

      key = T::Private::Methods.send(:method_owner_and_name_to_key, owner, method_name)
      sig_wrappers = T::Private::Methods.instance_variable_get(:@sig_wrappers)
      method_object = if (wrapper = sig_wrappers[key])
        wrapper.call.method
      else
        owner.instance_method(method_name)
      end

      method_object.parameters
    end
  end
end
