# typed: strict

class StubTest < TLDR
  include Mocktail::DSL
  extend T::Sig

  class Thing
    extend T::Sig

    sig { params(an_arg: T.untyped).returns(T.untyped) }
    def lol(an_arg)
    end
  end

  sig { void }
  def test_thing
    thing = Mocktail.of(Thing)

    stubs { thing.lol(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], thing.lol(42)
    assert_nil thing.lol(41)
    assert_raises(ArgumentError) { T.unsafe(thing).lol }
    assert_raises(ArgumentError) { T.unsafe(thing).lol(4, 2) }
  end

  sig { void }
  def test_non_dsl_is_also_fine
    thing = Mocktail.of(Thing)

    Mocktail.stubs { thing.lol(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], thing.lol(42)
    assert_nil thing.lol(41)
    assert_raises(ArgumentError) { T.unsafe(thing).lol }
    assert_raises(ArgumentError) { T.unsafe(thing).lol(4, 2) }
  end

  require "bigdecimal"
  class Reminder
  end

  sig { void }
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

  sig { void }
  def test_stub_with_not_matcher
    thing = Mocktail.of(Thing)

    stubs { |m| thing.lol(m.not(:banana)) }.with { :a }

    assert_equal :a, thing.lol(:orange)
    assert_nil thing.lol(:banana)
  end

  class ArgyDoo
    extend T::Sig

    sig { params(a: T.untyped, b: T.untyped, c: T.untyped, blk: T.untyped).returns(T.untyped) }
    def boo(a = nil, b: nil, c: nil, &blk)
      raise "Boo!"
    end
  end

  sig { void }
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

  sig { void }
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
    extend T::Sig

    sig { params(route: T.untyped, action: T.untyped).returns(T.untyped) }
    def get(route, &action)
      raise "real call made"
    end
  end

  class Fouter
    extend T::Sig

    sig { params(fttp: T.untyped).void }
    def initialize(fttp)
      @fttp = fttp
    end

    sig { returns(T.untyped) }
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
    extend T::Sig

    sig { params(head_only: T.untyped).void }
    def initialize(head_only: false)
      @head_only = head_only
    end

    sig { returns(T.untyped) }
    def head_only?
      @head_only
    end
  end

  class Fres
    extend T::Sig

    sig { void }
    def initialize
      @written = T.let([], T::Array[T.untyped])
    end

    sig { params(content: T.untyped).returns(T.untyped) }
    def write(content)
      @written << content
    end

    sig { returns(T.untyped) }
    def flush
      @written.join
    end
  end

  sig { void }
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

  sig { void }
  def test_zero_calls_per_stub
    thing = Mocktail.of(Thing)

    e = assert_raises(Mocktail::MissingDemonstrationError) do
      stubs { thing }.with { thing }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      `stubs` & `verify` expect an invocation of a mocked method by a passed
      block, but no invocation occurred.
    MSG
  end

  sig { void }
  def test_forlols_the_with
    thing = Mocktail.of(Thing)

    stubs { thing.lol(42) }

    assert_nil thing.lol(42)
  end

  class DoesTooMuch
    extend T::Sig

    sig { params(this: T.untyped, that: T.untyped, and: T.untyped, also: T.untyped, block: T.untyped).returns(T.untyped) }
    def do(this, that = nil, and:, also: "this", &block)
      raise "LOL"
    end

    sig { params(a: T.untyped, this: T.untyped, b: T.untyped, that: T.untyped).returns(T.untyped) }
    def splats(a, *this, b:, **that)
    end
  end

  sig { void }
  def test_param_checking
    does_too_much = Mocktail.of(DoesTooMuch)

    assert_raises(ArgumentError) { T.unsafe(does_too_much).do }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do { 1 } }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(and: 1) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(and: 1) { 2 } }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, 2) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, 2, also: 3) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, 2, also: 3) { 4 } }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, also: 3) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, and: 2, fake_keyword: 4) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).splats(12) }
    assert_raises(ArgumentError) { T.unsafe(does_too_much).splats(b: 4) }

    e = assert_raises(ArgumentError) { T.unsafe(does_too_much).do(1, 2, also: 3) { 4 } }
    # Make sure the backtrace doesn't contain gem library paths
    refute e.backtrace.any? { |frame|
      frame.match?(/mocktail\/(src|lib)/)
    }, "Library paths should not appear in backtrace:\n#{e.backtrace.join("\n")}"

    # Make sure the message contains the call
    assert_equal "missing keyword: :and [Mocktail call: `do(1, 2, also: 3) { Proc at test/safe/stub_test.rb:316 }']", e.message

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

  sig { void }
  def test_stub_with_is_passed_the_real_call_upon_satisfaction
    does_too_much = Mocktail.of(DoesTooMuch)

    stubs { |m| does_too_much.do(m.numeric, and: true) }.with { |call| call.args[0] + 13 }

    assert_nil does_too_much.do(:not_a_match, and: true)
    assert_equal 25, does_too_much.do(12, and: true)
  end

  sig { void }
  def test_stub_that_ignores_unspecified_blocks
    doo = Mocktail.of(ArgyDoo)

    stubs(ignore_block: true) { |m| doo.boo(m.numeric) }.with { "✅" }

    assert_equal "✅", doo.boo(42)
    assert_equal "✅", doo.boo(256) { :lol_a_block }
    assert_nil doo.boo("42")
  end

  sig { void }
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

  sig { void }
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

  sig { void }
  def test_stub_ignoring_arity_restrictions
    does_too_much = Mocktail.of(DoesTooMuch)

    stubs(ignore_extra_args: true, ignore_arity: true) { T.unsafe(does_too_much).do }.with { "yahtzee" }

    assert_equal "yahtzee", does_too_much.do(1, and: 2)
  end

  sig { void }
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

  class ThingThatDoesMethodMissingStuff
    extend T::Sig

    sig { returns(T.untyped) }
    def real_method?
      true
    end

    sig { params(name: T.untyped, args: T.untyped, kwargs: T.untyped, blk: T.untyped).returns(T.untyped) }
    def method_missing(name, *args, **kwargs, &blk)
      {
        name: name,
        args: args,
        kwargs: kwargs,
        blk: blk
      }
    end

    sig { params(name: T.untyped, private_methods: T.untyped).returns(T.untyped) }
    def respond_to_missing?(name, private_methods = false)
      name.start_with?("a")
    end
  end

  sig { void }
  def test_handling_thing_that_does_method_missing_stuff
    # see: https://github.com/ruby/ruby/blob/d92f09a5eea009fa28cd046e9d0eb698e3d94c5c/spec/ruby/language/def_spec.rb#L65
    # and: https://github.com/ruby/ruby/blob/eaeb0a008ba13ba0e531f3ccf589c44351cddbfe/vm_method.c#L776-L787
    subject = Mocktail.of(ThingThatDoesMethodMissingStuff)

    stubs { |m| subject.send(:respond_to_missing?, m.any, m.any) }.with { |call|
      call.args[0].start_with?("b")
    }
    stubs(ignore_extra_args: true, ignore_arity: true) { T.unsafe(subject).method_missing }.with { |call|
      "#{call.method}|#{call.args.map(&:inspect).join(", ")}|#{call.kwargs.map { |k, v| "#{k}: #{v}" }.join(", ")}"
    }
    stubs { subject.real_method? }.with { :lol }

    assert_equal :lol, subject.real_method?
    assert_equal false, subject.respond_to?(:alpha)
    assert_equal true, subject.respond_to?(:beta)
    assert_equal false, subject.respond_to?(:charlie)

    assert_equal "method_missing|:beta, :panda|cool: 4", T.unsafe(subject).beta(:panda, cool: 4)
  end

  sig { void }
  def test_unsatisfied_stubbings_are_falsey_lol_whoops
    thing = Mocktail.of(Thing)

    stubs { thing.lol(:correct) }.with { true }

    unsatisfied_return_value = thing.lol(:incorrect)
    assert_nil unsatisfied_return_value
    if unsatisfied_return_value
      fail "An unsatisfied stubbing returned a truthy value!!!"
    end
  end

  class Methodless
  end

  sig { void }
  def test_default_method_missing_warnings
    methodless = Mocktail.of(Methodless)

    e = assert_raises(NoMethodError) {
      stubs { T.unsafe(methodless).do_stuff(42, a: 4) { |blk| blk.call } }.with { :value! }
    }
    assert_match <<~MSG, e.message
      No method `StubTest::Methodless#do_stuff' exists for call:

        do_stuff(42, a: 4) {…}

      Need to define the method? Here's a sample definition:

        def do_stuff(arg, a:, &blk)
        end

    MSG
  end

  class Checkable
    extend T::Sig

    sig { returns(T.untyped) }
    def check
      raise "unimplemented"
    end
  end

  class ValidatesThing
    extend T::Sig

    sig { params(checkable: T.untyped).void }
    def initialize(checkable)
      @checkable = checkable
    end

    sig { params(thing: T.untyped).returns(T.untyped) }
    def validate(thing)
      @checkable.check { thing[:email].include?("@") }
    end
  end

  # Methods that don't declare a block arg can still yield to a block, so
  # we need to make sure that our generated signatures don't break that.
  sig { void }
  def test_implicit_block_arg
    checkable = Mocktail.of(Checkable)
    validates_thing = ValidatesThing.new(checkable)

    stubs { T.unsafe(checkable).check { |blk| blk.call == true } }.with { :valid }

    stubs { T.unsafe(checkable).check { |blk| blk.call != true } }.with { :invalid }

    assert_equal validates_thing.validate({email: "foo@bar"}), :valid
    assert_equal validates_thing.validate({email: "foobar"}), :invalid
  end

  class ThingWithBadlyOrderedArgs
    extend T::Sig

    # Have to dynamically add the method b/c sorbet sig{} will error with:
    # "Required params after optional params are not supported in method declarations"
    # sig { params(a: T.untyped, b: T.untyped, c: T.untyped, d: T.untyped, e: T.untyped).returns(T.untyped) }
    eval <<~RUBY, binding, __FILE__, __LINE__ + 1 # standard:disable Security/Eval
      def positional(a, b = nil, c = nil, d, e)
      end
    RUBY
  end

  sig { void }
  def test_out_of_order_args_work
    thing = Mocktail.of(ThingWithBadlyOrderedArgs)

    stubs { T.unsafe(thing).positional(:a, :d, :e) }.with { :weird }
    stubs { T.unsafe(thing).positional(:a, :b, :d, :e) }.with { :less_weird }
    stubs { T.unsafe(thing).positional(:a, :b, :c, :d, :e) }.with { :even_less_weird }

    assert_equal :weird, T.unsafe(thing).positional(:a, :d, :e)
    assert_equal :less_weird, T.unsafe(thing).positional(:a, :b, :d, :e)
    assert_equal :even_less_weird, T.unsafe(thing).positional(:a, :b, :c, :d, :e)

    assert_equal [:a, :d, :e], Mocktail.calls(thing, :positional)[0]&.args
    assert_equal [:a, :b, :d, :e], Mocktail.calls(thing, :positional)[1]&.args
    assert_equal [:a, :b, :c, :d, :e], Mocktail.calls(thing, :positional)[2]&.args
  end
end
