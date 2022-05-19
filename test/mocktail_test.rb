# typed: true
require "test_helper"

class MocktailTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Mocktail::VERSION
  end
end
