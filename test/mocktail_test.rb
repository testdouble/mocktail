# typed: strict

class MocktailTest < TLDR
  extend T::Sig

  sig { void }
  def test_that_it_has_a_version_number
    refute_nil ::Mocktail::VERSION
  end
end
