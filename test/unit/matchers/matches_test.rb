# typed: true

require "test_helper"

module Mocktail::Matchers
  class GoodMatch
    def match?(other)
      true
    end
  end

  class BadMatch
    def match?(*args)
      raise "💥"
    end
  end

  class WrongMatch
    def match?
    end
  end

  class MatchesTest < Minitest::Test
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
