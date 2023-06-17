# typed: true

require "test_helper"

class DslTest < Minitest::Test
  def test_that_stubs_and_verifies_have_matching_options
    assert_equal unwrap(Mocktail.method(:stubs)).parameters, unwrap(Mocktail.method(:verify)).parameters
  end

  def unwrap(method)
    T::Private::Methods.signature_for_method(method)
  end
end
