# typed: strict

require "test_helper"

class SherbetTest < Minitest::Test
  class Sherbet
    extend T::Sig

    sig { returns(Symbol) }
    attr_reader :flavor

    sig { void }
    def initialize
      @flavor = T.let(:orange, Symbol)
    end
  end

  extend T::Sig

  sig { void }
  def test_stubbing
    sherbet = Mocktail.of(Sherbet)
    T.assert_type!(sherbet, Sherbet)

    stubs { sherbet.flavor }.with { :strawberry }

    assert_equal :strawberry, sherbet.flavor
    T.assert_type!(sherbet.flavor, Symbol)
  end

  sig { void }
  def test_of_next
    sherbet = Mocktail.of_next(Sherbet)

    assert_equal sherbet, Sherbet.new
  end

  sig { void }
  def test_alias_of_next_with_count
    sherbets = Mocktail.of_next_with_count(Sherbet, count: 2)

    assert_equal 2, sherbets.size
  end
end
