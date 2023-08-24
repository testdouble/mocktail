# typed: strict

require "test_helper"

class OfNextTest < Minitest::Test
  include Mocktail::DSL
  extend T::Sig

  sig { void }
  def teardown
    Mocktail.reset
  end

  class Neato
    extend T::Sig

    sig { returns(T.untyped) }
    def is_neato?
      true
    end
  end

  class Argz
    extend T::Sig

    sig { params(a: T.untyped, b: T.untyped).void }
    def initialize(a, b:)
      raise "args required!"
    end
  end

  sig { void }
  def test_of_next
    neato_mocktail = Mocktail.of_next(Neato)
    next_neato = Neato.new
    third_neato = Neato.new

    # Next time someone calls new on the thing, they get the exact same mocktail
    assert_same neato_mocktail, next_neato
    # And it's unwound
    assert_equal Neato, third_neato.class
  end

  sig { void }
  def test_of_next_multiples_then_returns_to_normal
    skip unless runtime_type_checking_disabled?

    five_things = T.unsafe(Mocktail).of_next(Argz, count: 5)

    assert_equal five_things[0], Argz.new(42, b: true)
    assert_equal five_things[1], Argz.new(1337, b: false)
    assert_equal five_things[2], Argz.new(nil, b: nil)
    assert_equal five_things[3], Argz.new(nil, b: nil)
    assert_equal five_things[4], Argz.new(nil, b: nil)
    e = assert_raises { Argz.new(true, b: false) }
    assert_equal "args required!", e.message
  end

  sig { void }
  def test_of_next_multiples_with_alias_method
    two_things = Mocktail.of_next_with_count(Argz, 2)

    assert_equal two_things[0], Argz.new(42, b: true)
    assert_equal two_things[1], Argz.new(1337, b: false)
    e = assert_raises { Argz.new(true, b: false) }
    assert_equal "args required!", e.message
  end

  sig { void }
  def test_of_single_with_array_typed_alias_method
    one_things = Mocktail.of_next_with_count(Argz, 1)

    assert_equal 1, one_things.size
    assert_equal one_things[0], Argz.new(42, b: true)
    e = assert_raises { Argz.new(true, b: false) }
    assert_equal "args required!", e.message
  end

  sig { void }
  def test_of_next_multiples_then_returns_to_replaced_version_when_runtime_is_disabled
    skip unless runtime_type_checking_disabled?

    Mocktail.replace(Neato)
    # of_next is still supported even though of_next_with_count is typesafe:
    three_neats = T.unsafe(Mocktail).of_next(Neato, count: 3)

    assert_equal three_neats[0], Neato.new
    assert_equal three_neats[1], Neato.new
    assert_equal three_neats[2], Neato.new
    assert Neato.new.to_s.include?("Mocktail")
  end

  sig { void }
  def test_of_next_multiples_raises_error_when_runtime_is_enabled
    skip if runtime_type_checking_disabled?

    Mocktail.replace(Neato)

    e = assert_raises(Mocktail::TypeCheckingError) {
      T.unsafe(Mocktail).of_next(Neato, count: 3)
    }
    assert_equal <<~MSG, e.message
      Calling `Mocktail.of_next()' with a `count' value other than 1 is not supported when
      type checking is enabled. There are two ways to fix this:

      1. Use `Mocktail.of_next_with_count(type, count)' instead, which will always return
         an array of fake objects.

      2. Disable runtime type checking by setting `T::Private::RuntimeLevels.default_checked_level = :never'
         or by setting the envronment variable `SORBET_RUNTIME_DEFAULT_CHECKED_LEVEL=never'
    MSG
  end

  module AModule
  end

  sig { void }
  def test_not_a_class
    e = SorbetOverride.disable_call_validation_checks do
      assert_raises(Mocktail::UnsupportedMocktail) { T.unsafe(Mocktail).of_next(AModule) }
    end
    assert_equal <<~MSG.chomp, e.message
      Mocktail.of_next() only supports classes
    MSG
  end

  sig { void }
  def test_multiple_threads
    [
      thread do
        mock_neatos = Mocktail.of_next_with_count(Neato, 3)
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
