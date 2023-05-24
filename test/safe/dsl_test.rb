# typed: true

require "test_helper"

class DslTest < Minitest::Test
  def test_that_stubs_and_verifies_have_matching_options
    assert_equal Mocktail.method(:stubs).parameters, Mocktail.method(:verify).parameters
  end
end
