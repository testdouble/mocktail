# typed: strict

class RegistersMatcherTest < TLDR
  extend T::Sig

  sig { void }
  def initialize
    super

    @subject = T.let(Mocktail::RegistersMatcher.new, Mocktail::RegistersMatcher)
  end

  class ValidMatcher < Mocktail::Matchers::Base
    extend T::Sig

    sig { params(expected: T.untyped).void }
    def initialize(expected)
      @expected = expected
    end

    sig { returns(Symbol) }
    def self.matcher_name
      :is_pants
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      @expected == actual
    end

    sig { returns(String) }
    def inspect
      "m.is_pants(#{T.cast(@expected, Object).inspect})"
    end

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  sig { void }
  def test_works_fine_if_the_matcher_is_legit
    @subject.register(ValidMatcher)

    matching_pants = T.unsafe(Mocktail.matchers).is_pants("pants")
    not_matching_pants = T.unsafe(Mocktail.matchers).is_pants("trousers")

    assert matching_pants.match?("pants")
    refute matching_pants.match?("trousers")
    assert_equal "m.is_pants(\"pants\")", matching_pants.inspect

    assert not_matching_pants.match?("trousers")
    refute not_matching_pants.match?("pants")
    assert_equal "m.is_pants(\"trousers\")", not_matching_pants.inspect
  end

  class MissingNameMatcher < Mocktail::Matchers::Base
    extend T::Sig

    class << self
      undef_method(:matcher_name)
    end

    sig { returns(T::Boolean) }
    def match?
      false
    end

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  class InvalidNameMatcher
    extend T::Sig

    sig { returns(T.untyped) }
    def self.matcher_name
      "42"
    end

    sig { returns(T::Boolean) }
    def match?
      false
    end

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  sig { void }
  def test_blows_up_when_misnamed
    skip unless runtime_type_checking_disabled?

    [MissingNameMatcher, InvalidNameMatcher].each do |matcher_type|
      e = assert_raises(Mocktail::InvalidMatcherError) do
        @subject.register(T.unsafe(matcher_type))
      end
      assert_equal <<~MSG.tr("\n", " "), e.message
        #{matcher_type.name}.matcher_name must return a valid method name
      MSG
    end
  end

  class NoMatchMatcher < Mocktail::Matchers::Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :no_match
    end

    undef_method :match?

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  class BadMatchMatcher
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :bad_match
    end

    sig { returns(T.untyped) }
    def match?
    end

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  sig { void }
  def test_blows_up_when_bad_match?
    skip unless runtime_type_checking_disabled?

    [NoMatchMatcher, BadMatchMatcher].each do |matcher_type|
      e = assert_raises(Mocktail::InvalidMatcherError) do
        @subject.register(T.unsafe(matcher_type))
      end
      assert_equal <<~MSG.tr("\n", " "), e.message
        #{matcher_type.name}#match? must be defined as a one-argument method
      MSG
    end
  end

  module Lol
    extend T::Sig

    sig { returns(T.untyped) }
    def self.matcher_name
      :lol
    end

    sig { returns(T::Boolean) }
    def match?
      false
    end

    sig { returns(T::Boolean) }
    def is_mocktail_matcher?
      true
    end
  end

  sig { void }
  def test_blows_up_when_not_a_class
    skip unless runtime_type_checking_disabled?

    e = assert_raises(Mocktail::InvalidMatcherError) do
      T.unsafe(@subject).register(Lol)
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      Matchers must be Ruby classes
    MSG
  end

  class MissingFlagMatcher < Mocktail::Matchers::Base
    extend T::Sig
    undef_method(:is_mocktail_matcher?)

    sig { returns(Symbol) }
    def self.matcher_name
      :missing_flag
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      false
    end
  end

  sig { void }
  def test_blows_up_without_flag
    e = assert_raises(Mocktail::InvalidMatcherError) do
      @subject.register(MissingFlagMatcher)
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      RegistersMatcherTest::MissingFlagMatcher#is_mocktail_matcher? must be defined
    MSG
  end
end
