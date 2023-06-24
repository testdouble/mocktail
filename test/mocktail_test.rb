# typed: strict

require "test_helper"

class MocktailTest < Minitest::Test
  extend T::Sig

  sig { void }
  def test_that_it_has_a_version_number
    refute_nil ::Mocktail::VERSION
  end
end
