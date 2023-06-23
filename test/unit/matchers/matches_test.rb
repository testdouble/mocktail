# typed: strict

require "test_helper"

module Mocktail::Matchers
  class GoodMatch
    extend T::Sig

    sig { params(other: T.untyped).returns(T.untyped) }
    def match?(other)
      true
    end
  end

  class BadMatch
    extend T::Sig

    sig { params(args: T.untyped).returns(T.untyped) }
    def match?(*args)
      raise "💥"
    end
  end

  class WrongMatch
    extend T::Sig

    sig { returns(T.untyped) }
    def match?
    end
  end

  class MatchesTest < Minitest::Test
    extend T::Sig

    sig { void }
    def test_some_matches
      assert_equal "matches(\"name\")", Matches.new("name").inspect

      assert Matches.new("foo").match?("foobar")
      assert Matches.new(/\d/).match?("4")
      refute Matches.new(/\s/).match?("nospace")
      assert Matches.new("foo").match?(GoodMatch.new)
      refute Matches.new("foo").match?(BadMatch.new)
      refute Matches.new("foo").match?(WrongMatch.new)
    end
  end
end
