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
    # T.unsafe(binding).irb
    assert_equal :tiny, sherbet.lick(size: 1)
    #    assert_equal :tiny, sherbet.lick(size: T.unsafe(nil))

    assert_equal :skosh, sherbet.lick(size: 2, sound: "yum")
    assert_equal :skosh, sherbet.lick(size: 2)
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
