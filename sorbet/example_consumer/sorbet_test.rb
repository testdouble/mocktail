# typed: true

require "sorbet-runtime"

class Sherbet
  extend T::Sig

  sig { returns(Symbol) }
  attr_reader :flavor

  def initialize
    @flavor = :orange
  end
end

require "mocktail"
require "minitest/autorun"

class SherbetTest < Minitest::Test
  include Mocktail::DSL

  def test_stubbing
    sherbet = Mocktail.of_next(Sherbet)

    stubs { sherbet.flavor }.with { :strawberry }

    assert_equal :strawberry, sherbet.flavor
  end

  def test_alias_of_next_with_count
    sherbets = Mocktail.of_next_with_count(Sherbet, count: 2)

    assert_equal 2, sherbets.size
  end
end
