require "test_helper"

class RegistersMatcherTest < Minitest::Test
  def setup
    @subject = Mocktail::RegistersMatcher.new
  end

  class ValidMatcher
    def initialize(expected)
      @expected = expected
    end

    def self.matcher_name
      :is_pants
    end

    def match?(actual)
      @expected == actual
    end

    def inspect
      "m.is_pants(#{@expected.inspect})"
    end

    def is_mocktail_matcher?
      true
    end
  end

  def test_works_fine_if_the_matcher_is_legit
    @subject.register(ValidMatcher)

    matching_pants = Mocktail.matchers.is_pants("pants")
    not_matching_pants = Mocktail.matchers.is_pants("trousers")

    assert matching_pants.match?("pants")
    refute matching_pants.match?("trousers")
    assert_equal "m.is_pants(\"pants\")", matching_pants.inspect

    assert not_matching_pants.match?("trousers")
    refute not_matching_pants.match?("pants")
    assert_equal "m.is_pants(\"trousers\")", not_matching_pants.inspect
  end

  class MissingNameMatcher
    def match?
      false
    end

    def is_mocktail_matcher?
      true
    end
  end

  class InvalidNameMatcher
    def self.matcher_name
      "42"
    end

    def match?
      false
    end

    def is_mocktail_matcher?
      true
    end
  end

  def test_blows_up_when_misnamed
    [MissingNameMatcher, InvalidNameMatcher].each do |matcher_type|
      e = assert_raises(Mocktail::InvalidMatcherError) do
        @subject.register(matcher_type)
      end
      assert_equal <<~MSG.tr("\n", " "), e.message
        #{matcher_type.name}.matcher_name must return a valid method name
      MSG
    end
  end

  class NoMatchMatcher
    def self.matcher_name
      :no_match
    end

    def is_mocktail_matcher?
      true
    end
  end

  class BadMatchMatcher
    def self.matcher_name
      :bad_match
    end

    def match?
    end

    def is_mocktail_matcher?
      true
    end
  end

  def test_blows_up_when_bad_match?
    [NoMatchMatcher, BadMatchMatcher].each do |matcher_type|
      e = assert_raises(Mocktail::InvalidMatcherError) do
        @subject.register(matcher_type)
      end
      assert_equal <<~MSG.tr("\n", " "), e.message
        #{matcher_type.name}#match? must be defined as a one-argument method
      MSG
    end
  end

  module Lol
    def self.matcher_name
      :lol
    end

    def match?
      false
    end

    def is_mocktail_matcher?
      true
    end
  end

  def test_blows_up_when_not_a_class
    e = assert_raises(Mocktail::InvalidMatcherError) do
      @subject.register(Lol)
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      Matchers must be Ruby classes
    MSG
  end

  class MissingFlagMatcher
    def self.matcher_name
      :missing_flag
    end

    def match?(actual)
      false
    end
  end

  def test_blows_up_without_flag
    e = assert_raises(Mocktail::InvalidMatcherError) do
      @subject.register(MissingFlagMatcher)
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      RegistersMatcherTest::MissingFlagMatcher#is_mocktail_matcher? must be defined
    MSG
  end
end
