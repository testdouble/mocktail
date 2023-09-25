# typed: strict

class DslTest < TLDR
  extend T::Sig

  sig { void }
  def test_that_stubs_and_verifies_have_matching_options
    assert_equal unwrap(Mocktail.method(:stubs)).parameters, unwrap(Mocktail.method(:verify)).parameters
  end

  sig { params(method: Method).returns(T.any(T::Private::Methods::Signature, Method)) }
  def unwrap(method)
    T::Private::Methods.signature_for_method(method) || method
  end
end
