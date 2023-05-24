# typed: true

require "test_helper"

class OfNextTest < Minitest::Test
  include Mocktail::DSL

  def teardown
    Mocktail.reset
  end

  class Neato
    def is_neato?
      true
    end
  end

  class Argz
    def initialize(a, b:)
      raise "args required!"
    end
  end

  def test_of_next
    neato_mocktail = Mocktail.of_next(Neato)
    next_neato = Neato.new
    third_neato = Neato.new

    # Next time someone calls new on the thing, they get the exact same mocktail
    assert_same neato_mocktail, next_neato
    # And it's unwound
    assert_equal Neato, third_neato.class
  end

  def test_of_next_multiples_then_returns_to_normal
    five_things = Mocktail.of_next(Argz, count: 5)

    assert_equal five_things[0], Argz.new(42, b: true)
    assert_equal five_things[1], Argz.new(1337, b: false)
    assert_equal five_things[2], Argz.new(nil, b: nil)
    assert_equal five_things[3], Argz.new(nil, b: nil)
    assert_equal five_things[4], Argz.new(nil, b: nil)
    e = assert_raises { Argz.new(true, b: false) }
    assert_equal "args required!", e.message
  end

  def test_of_next_multiples_then_returns_to_replaced_version
    Mocktail.replace(Neato)
    three_neats = Mocktail.of_next(Neato, count: 3)

    assert_equal three_neats[0], Neato.new
    assert_equal three_neats[1], Neato.new
    assert_equal three_neats[2], Neato.new
    assert Neato.new.to_s.include?("Mocktail")
  end

  module AModule
  end

  def test_not_a_class
    e = assert_raises(Mocktail::UnsupportedMocktail) { Mocktail.of_next(AModule) }
    assert_equal <<~MSG.chomp, e.message
      Mocktail.of_next() only supports classes
    MSG
  end

  def test_multiple_threads
    [
      thread do
        mock_neatos = Mocktail.of_next(Neato, count: 3)
        sleep 0.001
        assert_equal mock_neatos[0], Neato.new
        sleep 0.001
        assert_equal mock_neatos[1], Neato.new
        sleep 0.001
        assert_equal mock_neatos[2], Neato.new
        sleep 0.001
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
      end,
      thread do
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
        sleep 0.001
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
        sleep 0.001
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
      end,
      thread do
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
        Mocktail.replace(Neato)
        neato = Neato.new
        stubs { neato.is_neato? }.with { false }
        refute neato.is_neato?
      end,
      thread do
        assert Neato.new.class == Neato # standard:disable Style/ClassEqualityComparison
        Mocktail.of_next(Neato)
        sleep 0.001
        neato = Neato.new
        sleep 0.001
        stubs { neato.is_neato? }.with { 42 }
        sleep 0.001
        assert_equal 42, neato.is_neato?
      end
    ].flatten.shuffle.each(&:join)
  end
end
