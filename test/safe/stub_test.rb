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

  def test_stub_with_not_matcher
    thing = Mocktail.of(Thing)

    stubs { |m| thing.lol(m.not(:banana)) }.with { :a }

    assert_equal :a, thing.lol(:orange)
    assert_nil thing.lol(:banana)
  end

  class ArgyDoo
    def boo(a = nil, b: nil, c: nil, &blk)
      raise "Boo!"
    end
  end

  def test_stub_with_lotsa_matchers
    doo = Mocktail.of(ArgyDoo)

    stubs { |m| doo.boo }.with { :a }
    stubs { |m| doo.boo(m.any) }.with { :b }
    stubs { |m| doo.boo(m.numeric, b: m.is_a(Symbol)) }.with { :c }
    stubs { |m| doo.boo(m.includes("🤔"), b: m.that { |b| b < 10 }, c: 1) }.with { :d }

    assert_equal :a, doo.boo
    assert_equal :b, doo.boo(:lol)
    assert_equal :c, doo.boo(42, b: :kek)
    assert_nil doo.boo(42, b: :kek, c: nil)
    assert_nil doo.boo("42", b: :kek)
    assert_nil doo.boo(42, b: nil)
    assert_nil doo.boo(nil, b: 42)
    assert_equal :d, doo.boo("hmm 🤔", b: 5, c: 1)
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

  class Fttp
    def get(route, &action)
      raise "real call made"
    end
  end

  class Fouter
    def initialize(fttp)
      @fttp = fttp
    end

    def draw
      routes = []
      routes << @fttp.get("/foo") do |req, res|
        res.write("neat")
      end

      routes << @fttp.get("/bar") do |req, res|
        next if req.head_only?
        res.write "gee whiz"
      end

      routes << @fttp.get("/baz") do
        raise "wups"
      end

      routes << @fttp.get("/baz")

      routes
    end
  end

  class Freq
    def initialize(head_only: false)
      @head_only = head_only
    end

    def head_only?
      @head_only
    end
  end

  class Fres
    def initialize
      @written = []
    end

    def write(content)
      @written << content
    end

    def flush
      @written.join
    end
  end

  def test_block_stubbing
    fttp = Mocktail.of(Fttp)
    fouter = Fouter.new(fttp)

    # satisfied when block is sent (and the demo here returns truthy)
    stubs { fttp.get("/baz") { true } }.with { :a }
    # satisfied when no block is provided by subject
    stubs { fttp.get("/baz") }.with { :b }
    # unsatisfied when block is sent because demo block returns false
    stubs { fttp.get("/baz") { false } }.with { :c }

    # Super verbose, but also v complex! Stubbing based on observable
    # behavior of passed block
    #
    # unsatisifed because it writes neat
    stubs {
      fttp.get("/foo") { |actual_block|
        actual_block.call(nil, fres = Fres.new)
        fres.flush.end_with?("cool")
      }
    }.with { :d }
    # satsfied because it writes neat
    stubs {
      fttp.get("/foo") { |actual_block|
        actual_block.call(nil, fres = Fres.new)
        fres.flush.end_with?("neat")
      }
    }.with { :e }
    # not satisfied because it writes neat
    stubs {
      fttp.get("/foo") { |actual_block|
        actual_block.call(nil, fres = Fres.new)
        fres.flush.end_with?("slick")
      }
    }.with { :f }

    # You can call the block as much as you want to fully exercise it, if you're
    # into that kind of thing. Beyond a trivial point, extracting this to a
    # real method makes a lot more sense because, like, this is ridiculous
    # looking to be encoding 6 layers deep in an isolated unit test. SRP etc
    stubs {
      fttp.get("/bar") { |actual_block|
        actual_block.call(Freq.new(head_only: true), fres1 = Fres.new)
        actual_block.call(Freq.new(head_only: false), fres2 = Fres.new)
        fres1.flush == "" && fres2.flush == ""
      }
    }.with { :g }
    # This is the matching one:
    stubs {
      fttp.get("/bar") { |actual_block|
        actual_block.call(Freq.new(head_only: true), fres1 = Fres.new)
        actual_block.call(Freq.new(head_only: false), fres2 = Fres.new)
        fres1.flush == "" && fres2.flush == "gee whiz"
      }
    }.with { :h }
    stubs {
      fttp.get("/bar") { |actual_block|
        actual_block.call(Freq.new(head_only: true), fres1 = Fres.new)
        actual_block.call(Freq.new(head_only: false), fres2 = Fres.new)
        fres1.flush == "" && fres2.flush == "golly gee"
      }
    }.with { :i }

    result = fouter.draw

    assert_equal [:e, :h, :a, :b], result
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

    def splats(a, *this, b:, **that)
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
    assert_raises(ArgumentError) { does_too_much.splats(12) }
    assert_raises(ArgumentError) { does_too_much.splats(b: 4) }

    # Make sure it doesn't raise:
    does_too_much.do(1, and: 2)
    does_too_much.do(1, and: 2) { 3 }
    does_too_much.do(1, 2, and: 3)
    does_too_much.do(1, 2, and: 3, also: 4)
    does_too_much.do(1, 2, and: 3, also: 4) { 5 }

    does_too_much.splats(2, b: 4)
    does_too_much.splats(2, 3, b: 4)
    does_too_much.splats(2, b: 4, c: 5)
    does_too_much.splats(2, 3, b: 4, c: 5)
  end

  def test_stub_with_is_passed_the_real_call_upon_satisfaction
    does_too_much = Mocktail.of(DoesTooMuch)

    stubs { |m| does_too_much.do(m.numeric, and: true) }.with { |call| call.args[0] + 13 }

    assert_nil does_too_much.do(:not_a_match, and: true)
    assert_equal 25, does_too_much.do(12, and: true)
  end

  def test_stub_that_ignores_unspecified_blocks
    doo = Mocktail.of(ArgyDoo)

    stubs(ignore_blocks: true) { |m| doo.boo(m.numeric) }.with { "✅" }

    assert_equal "✅", doo.boo(42)
    assert_equal "✅", doo.boo(256) { :lol_a_block }
    assert_nil doo.boo("42")
  end

  def test_stub_that_ignores_unspecified_args
    doo = Mocktail.of(ArgyDoo)

    stubs(ignore_extra_args: true) { |m| doo.boo { |real| real.call.is_a?(Integer) } }.with { "✅" }
    stubs(ignore_extra_args: true) { |m| doo.boo(m.that { |n| n < 50 }) { 1337 } }.with { "Cøøl" }

    assert_equal "Cøøl", doo.boo(42, b: :neat) { 1337 }
    assert_equal "✅", doo.boo(b: "cool") { 1 }
    assert_equal "✅", doo.boo { 2 }
    assert_nil doo.boo
    assert_nil doo.boo { "string" }
  end

  def test_stub_that_can_only_be_satisfied_so_many_times
    doo = Mocktail.of(ArgyDoo)

    stubs(times: 0) { doo.boo }.with { "hmm" }
    assert_nil doo.boo

    stubs(times: 1) { |m| doo.boo(m.numeric) }.with { :ok }
    assert_nil doo.boo("hi")
    assert_equal :ok, doo.boo(42)
    assert_nil doo.boo(42)

    stubs { |m| doo.boo(m.any) }.with { :fallback }
    stubs(times: 5) { |m| doo.boo(m.any) }.with { :back }
    stubs(times: 2) { |m| doo.boo(m.any) }.with { :front }

    2.times { |i| assert_equal :front, doo.boo(i) }
    5.times { |i| assert_equal :back, doo.boo(i) }
    3.times { |i| assert_equal :fallback, doo.boo(i) }
  end

  def test_stub_ignoring_arity_restrictions
    does_too_much = Mocktail.of(DoesTooMuch)

    stubs(ignore_extra_args: true, ignore_arity: true) { does_too_much.do }.with { "yahtzee" }

    assert_equal "yahtzee", does_too_much.do(1, and: 2)
  end

  def test_stub_calls_a_stub_in_effect
    thing_1 = Mocktail.of(Thing)
    thing_2 = Mocktail.of(Thing)

    stubs { thing_1.lol(4) }.with { 5 }
    stubs { thing_2.lol(4) }.with { thing_1.lol(4) + 1 }
    stubs { thing_1.lol(5) }.with { thing_1.lol(4) + 2 }
    stubs { thing_1.lol(6) }.with { thing_1.lol(6) }

    assert_equal 6, thing_2.lol(4)
    assert_equal 7, thing_1.lol(5)
  end
end
