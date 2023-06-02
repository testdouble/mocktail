# typed: strict

require "sorbet-runtime"

class Sherbet
  extend T::Sig

  sig { returns(Symbol) }
  attr_reader :flavor

  sig { void }
  def initialize
    @flavor = T.let(:orange, Symbol)
  end
end

require "mocktail"
require "minitest/autorun"

class SherbetTest < Minitest::Test
  extend T::Sig
  include Mocktail::DSL

  sig { void }
  def test_stubbing
    sherbet = Mocktail.of(Sherbet)

    stubs { sherbet.flavor }.with { :strawberry }

    assert_equal :strawberry, sherbet.flavor
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

  sig { void }
  def teardown
    Mocktail.reset
  end
end
