# typed: strict

require "test_helper"

class ReplaceTest < Minitest::Test
  include Mocktail::DSL
  extend T::Sig

  sig { void }
  def teardown
    Mocktail.reset
  end

  class Building
    extend T::Sig

    sig { params(uom: T.untyped).returns(T.untyped) }
    def self.size(uom:)
      raise "Unimplemented"
    end
  end

  class House < Building
    extend T::Sig

    sig { params(room_name: T.untyped).returns(T.untyped) }
    def self.room(room_name)
      raise "Unimplemented"
    end

    sig { params(title: T.untyped, features: T.untyped, tap: T.untyped).returns(T.untyped) }
    def self.summarize(title = nil, features: [], &tap)
      raise "Unimplemented"
    end

    sig { params(location: T.untyped).void }
    def initialize(location)
      raise "Unimplemented"
    end

    sig { returns(T.untyped) }
    def id
      raise "Unimplemented"
    end
  end

  sig { void }
  def test_replace_class
    return_value = Mocktail.replace(House)

    assert_nil_or_void return_value

    # None of these call through, so none blow up
    House.room("living")
    House.size(uom: "ft")
    House.summarize("Madiera", features: [:walls, :floor]) { "🆒" }

    # Argument errors still propogate
    assert_raises(ArgumentError) { House.room(wrong: :arg) }
    assert_raises(ArgumentError) { T.unsafe(House).size }
    assert_raises(ArgumentError) { T.unsafe(House).summarize("title", "wups") }

    # verification works
    verify { House.room("living") }
    verify { |m| House.size(uom: m.is_a(String)) }
    verify { |m| House.summarize("Madiera", features: m.includes(:walls, :floor)) { |real| real.call == "🆒" } }

    # stubbing works
    stubs { House.room("dining") }.with { "🍽" }
    stubs { House.size(uom: "m") }.with { "📏" }
    stubs { House.summarize }.with { "😶" }

    assert_equal "🍽", House.room("dining")
    assert_equal "📏", House.size(uom: "m")
    assert_equal "😶", House.summarize

    # new() does require proper params and can be verified
    assert_raises(ArgumentError) { T.unsafe(House).new }
    house = House.new(:some_latlong)

    verify { House.new(:some_latlong) }

    other_house = House.new(:a_map)
    refute_same other_house, house

    stubs { house.id }.with { 4 }
    stubs { other_house.id }.with { 8 }

    assert_equal 4, house.id
    assert_equal 8, other_house.id

    stubs { T.unsafe(House).new(:lol) }.with { :wat }

    assert_equal :wat, House.new(:lol)

    Thread.new {
      e = assert_raises { House.new(:foo) }
      assert_equal "Unimplemented", e.message
    }.tap { |t| t.abort_on_exception = true }.join

    error = assert_raises(NoMethodError) { T.unsafe(House).color }
    assert_match(/No method `ReplaceTest::House\.color'/, error.message)
    assert_match(/def self.color\n  end/, error.message)
  end

  module Home
    extend T::Sig

    sig { returns(T.untyped) }
    def self.is_cozy?
      raise "Nope"
    end

    sig { params(family: T.untyped).returns(T.untyped) }
    def self.family=(family)
      raise "unimplemented"
    end
  end

  sig { void }
  def test_replace_module
    Mocktail.replace(Home)

    stubs { Home.is_cozy? }.with { true }

    Home.family = [:person, :cat]

    verify { |m| Home.family = m.is_a(Array) }
  end

  sig { void }
  def test_multiple_threads
    [
      thread do
        Mocktail.replace(House)
        sleep 0.001
        stubs { |m| House.room(m.any) }.with { :ldk }
        sleep 0.001
        assert_equal :ldk, House.room(:lol)
      end,
      thread do
        Mocktail.replace(House)
        sleep 0.001
        assert_nil House.room(:lol)
        sleep 0.01
        assert_nil House.room(:lol)
      end,
      thread do
        Mocktail.replace(House)
        sleep 0.01
        assert_raises(Mocktail::VerificationError) { verify { |m| House.room(m.any) } }
      end,
      thread do
        Mocktail.replace(House)
        sleep 0.001
        stubs { |m| House.room(m.any) }.with { :kitchen }
        sleep 0.001
        assert_equal :kitchen, House.room(:lol)
      end,
      10.times.map { |i|
        thread do
          sleep 0.001 * i
          e = assert_raises { House.room("name") }
          assert_equal "Unimplemented", e.message
        end
      }
    ].flatten.shuffle.each(&:join)
  end

  sig { void }
  def test_not_a_module_or_a_class
    e = SorbetOverride.disable_call_validation_checks do
      assert_raises(Mocktail::UnsupportedMocktail) { T.unsafe(Mocktail).replace(42) }
    end
    assert_equal <<~MSG.chomp, e.message
      Mocktail.replace() only supports classes and modules
    MSG
  end
end
