require "minitest/autorun"
require "mocktail"

class AntitypeTest < Minitest::Test
  include Mocktail::DSL

  module Stuff
    def things(pants, shirts, sandals:)
    end
  end

  def test_mocking_modules
    stuff = Mocktail.of(Stuff)

    stubs(ignore_arity: true, ignore_extra_args: true) { stuff.things }.with { "things" }

    assert_equal "things", stuff.things(1, 2, sandals: 3)
  end

  class Stuffing
    include Stuff
  end

  def test_matchers
    stuff = Mocktail.of(Stuff)

    stubs { stuff.things(:zubon, :shatsu, sandals: false) }.with { "things" }
    stubs { |m| stuff.things(m.numeric, m.is_a(Stuff), sandals: m.includes(true)) }.with { "crap" }

    assert_equal "things", stuff.things(:zubon, :shatsu, sandals: false)
    assert_equal "crap", stuff.things(42, Stuffing.new, sandals: [true, false])
    assert_nil stuff.things(42, Stuffing.new, sandals: ["true"])
    assert_nil stuff.things("42", Stuffing.new, sandals: [true])
    assert_nil stuff.things(42, Stuffing, sandals: [true])

    stuff.things(:a, :b, sandals: :c)
    stuff.things(:c, :d, sandals: :e)
    stuff.things(:f, :g, sandals: :h)

    captor = Mocktail.captor
    verify { stuff.things(:c, captor.capture, sandals: :e) }
    assert_equal captor.value, :d
  end

  def test_sorbet_runtime_is_not_loaded
    refute $LOADED_FEATURES.any? { |feature|
      feature.include?("sorbet-runtime")
    }, "sorbet-runtime was required by something in mocktail. Features:\n\n#{$LOADED_FEATURES.join("\n")}"
  end

  def teardown
    Mocktail.reset
  end
end
