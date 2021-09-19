require "test_helper"

class StubTest < Minitest::Test
  include Mocktail::DSL

  class Thing
    def lol(an_arg)
    end
  end

  def test_thing
    thing = Mocktail.of(Thing)

    stubs { thing.lol(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], thing.lol(42)
    assert_nil thing.lol(41)
    assert_raises(ArgumentError) { thing.lol }
    assert_raises(ArgumentError) { thing.lol(4, 2) }
  end

  def test_non_dsl_is_also_fine
    thing = Mocktail.of(Thing)

    Mocktail.stubs { thing.lol(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], thing.lol(42)
    assert_nil thing.lol(41)
    assert_raises(ArgumentError) { thing.lol }
    assert_raises(ArgumentError) { thing.lol(4, 2) }
  end

  require "bigdecimal"
  class Reminder
  end

  def test_stub_with_matchers
    thing = Mocktail.of(Thing)

    stubs { |m| thing.lol(m.any) }.with { :a }
    stubs { |m| thing.lol(m.numeric) }.with { :b }
    stubs { |m| thing.lol(m.is_a(Reminder)) }.with { :c }
    stubs { |m| thing.lol(m.matches(/^foo/)) }.with { :d }
    stubs { |m| thing.lol(m.includes(:apple)) }.with { :e }
    stubs { |m| thing.lol(m.includes("pants")) }.with { :f }
    stubs { |m| thing.lol(m.that { |i| i.odd? }) }.with { :g }

    assert_equal :a, thing.lol(:trololol)
    assert_equal :b, thing.lol(42)
    assert_equal :b, thing.lol(42.0)
    assert_equal :b, thing.lol(BigDecimal("42"))
    assert_equal :c, thing.lol(Reminder.new)
    assert_equal :a, thing.lol(Reminder) # <- Reminder is a class!
    assert_equal :d, thing.lol("foobar")
    assert_equal :a, thing.lol("bazfoo") # <- doesn't match!
    assert_equal :e, thing.lol([:orange, :apple])
    assert_equal :f, thing.lol("my pants!")
    assert_equal :g, thing.lol(43)
  end

  def test_multiple_calls_per_stub
    thing = Mocktail.of(Thing)

    e = assert_raises(Mocktail::AmbiguousDemonstrationError) do
      stubs {
        thing.lol(1)
        thing.lol(2)
      }.with { [:r1, :r2] }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      `stubs` & `verify` expect exactly one invocation of a mocked method,
      but 2 were detected. As a result, Mocktail doesn't know which invocation
      to stub or verify.
    MSG
  end

  def test_zero_calls_per_stub
    thing = Mocktail.of(Thing)

    e = assert_raises(Mocktail::MissingDemonstrationError) do
      stubs { thing }.with { [:r1, :r2] }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      `stubs` & `verify` expect an invocation of a mocked method by a passed
      block, but no invocation occurred.
    MSG
  end

  def test_forlols_the_with
    thing = Mocktail.of(Thing)

    stubs { thing.lol(42) }

    assert_nil thing.lol(42)
  end

  class DoesTooMuch
    def do(this, that = nil, and:, also: "this", &block)
      raise "LOL"
    end
  end

  def test_param_checking
    does_too_much = Mocktail.of(DoesTooMuch)

    assert_raises(ArgumentError) { does_too_much.do }
    assert_raises(ArgumentError) { does_too_much.do { 1 } }
    assert_raises(ArgumentError) { does_too_much.do(1) }
    assert_raises(ArgumentError) { does_too_much.do(and: 1) }
    assert_raises(ArgumentError) { does_too_much.do(and: 1) { 2 } }
    assert_raises(ArgumentError) { does_too_much.do(1, 2) }
    assert_raises(ArgumentError) { does_too_much.do(1, 2, also: 3) }
    assert_raises(ArgumentError) { does_too_much.do(1, 2, also: 3) { 4 } }
    assert_raises(ArgumentError) { does_too_much.do(1, also: 3) }

    # Make sure it doesn't raise:
    does_too_much.do(1, and: 2)
    does_too_much.do(1, and: 2) { 3 }
    does_too_much.do(1, 2, and: 3)
    does_too_much.do(1, 2, and: 3, also: 4)
    does_too_much.do(1, 2, and: 3, also: 4) { 5 }
  end
end
