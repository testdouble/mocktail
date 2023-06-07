# typed: strict

require "test_helper"

T::Configuration.default_checked_level = :never
class SherbetTest < Minitest::Test
  class Sherbet
    extend T::Sig

    sig { returns(Symbol) }
    attr_reader :flavor

    sig { params(size: T.nilable(Integer), sound: T.untyped).returns(Symbol) }
    def lick(size: nil, sound: nil)
      return :none if size.nil?
      puts "Stop making this sound #{sound.inspect}"

      if size > 10
        :big
      elsif size > 5
        :medium
      else
        :small
      end
    end

    sig { void }
    def initialize
      @flavor = T.let(:orange, Symbol)
    end
  end

  include Mocktail::DSL
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
  def test_stubbing_with_all_dem_options
    sherbet = Mocktail.of(Sherbet)
    T.assert_type!(sherbet, Sherbet)

    Mocktail.stubs(
      ignore_block: true,
      ignore_extra_args: true,
      ignore_arity: nil,
      times: 4
    ) { sherbet.flavor }.with { :strawberry }

    assert_equal :strawberry, sherbet.flavor
    T.assert_type!(sherbet.flavor, Symbol)
  end

  sig { void }
  def test_stubbing_with_matchers
    sherbet = Mocktail.of(Sherbet)
    T.assert_type!(sherbet, Sherbet)

    stubs { |m|
      T.assert_type!(m, Mocktail::MatcherPresentation)
      sherbet.lick(size: m.is_a(Integer))
    }.with { :tiny }
    stubs { |m| sherbet.lick(size: 2, sound: m.any) }.with { :skosh }

    T.assert_type!(sherbet.lick(size: 5), Symbol)
    assert_equal :tiny, sherbet.lick(size: 1)
    assert_nil sherbet.lick(size: T.unsafe(nil))

    assert_equal :skosh, sherbet.lick(size: 2, sound: "yum")
    assert_equal :skosh, sherbet.lick(size: 2, sound: nil)
  end

  class MatcherThing
    extend T::Sig

    sig { params(array: T::Array[Symbol]).void }
    def takes_array(array)
    end

    sig { params(hash: T::Hash[Symbol, Integer]).void }
    def takes_hash(hash)
    end

    sig { params(string: String).void }
    def takes_string(string)
    end

    sig { params(integer: Integer).void }
    def takes_integer(integer)
    end
  end

  sig { void }
  def test_matchers_more_precisely
    thing = Mocktail.of(MatcherThing)

    stubs { |m| thing.takes_array(m.includes(:ham)) }.with { nil }
    stubs { |m| thing.takes_array(m.includes(:ham, :cheese)) }.with { nil }

    stubs { |m| thing.takes_hash(m.includes_key(:ham)) }.with { nil }
    stubs { |m| thing.takes_hash(m.includes_hash({cheese: 1}, {queso: 2})) }.with { nil }

    stubs { |m| thing.takes_string(m.includes_string("s")) }.with { nil }
    stubs { |m| thing.takes_string(m.includes_string("s", "t")) }.with { nil }

    stubs { |m| thing.takes_string(m.matches("s")) }.with { nil }
    stubs { |m| thing.takes_string(m.matches(/s/)) }.with { nil }

    stubs { |m| thing.takes_integer(m.numeric) }.with { nil }

    stubs { |m| thing.takes_integer(m.that { |i| i < 3 }) }.with { nil }

    stubs { |m| thing.takes_integer(m.not(3)) }.with { nil }
  end

  class Wastebin
    extend T::Sig

    sig {
      params(thing: Sherbet).void
    }
    def dump(thing)
    end
  end
  sig { void }
  def test_verify
    wastebin = Mocktail.of(Wastebin)
    sherbet = Mocktail.of(Sherbet)

    wastebin.dump(sherbet)

    verify { wastebin.dump(sherbet) }
    verify(
      ignore_block: true,
      ignore_extra_args: true,
      ignore_arity: nil,
      times: 1
    ) { wastebin.dump(sherbet) }
    verify(
      ignore_extra_args: true,
      ignore_arity: true
    ) { T.unsafe(wastebin).dump }
  end

  sig { void }
  def test_of_next
    sherbet = Mocktail.of_next(Sherbet, count: 1)
    T.assert_type!(sherbet, Sherbet)

    assert_equal sherbet, Sherbet.new
  end

  sig { void }
  def test_of_next_with_count
    sherbet = Mocktail.of_next_with_count(Sherbet, count: 2)
    T.assert_type!(sherbet, T::Array[Sherbet])
  end

  sig { void }
  def test_alias_of_next_with_count
    sherbets = Mocktail.of_next_with_count(Sherbet, count: 2)

    assert_equal 2, sherbets.size
  end
end
