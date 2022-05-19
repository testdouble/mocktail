# typed: true
require "test_helper"

module Mocktail::Matchers
  class IncludesTest < Minitest::Test
    def test_basic_includesing
      subject = Includes.new("a")

      assert_equal :includes, Includes.matcher_name
      assert_equal "includes(\"a\")", subject.inspect
      assert subject.is_mocktail_matcher?
      assert subject.match?(%w[a b c d])
      refute subject.match?(%w[b c d])
      refute subject.match?("ripple")
    end

    def test_multiple_args
      subject = Includes.new("a", "b")

      assert_equal "includes(\"a\", \"b\")", subject.inspect
      assert subject.match?(%w[a b c d])
      refute subject.match?(%w[b c d])
      refute subject.match?(%w[a c d])
      refute subject.match?("apple")
      assert subject.match?("bapple")
    end

    def test_hashes
      subject = Includes.new({a: 1, b: 2}, :d)

      assert subject.match?({a: 1, b: 2, c: 3, d: :lol})
      refute subject.match?({a: 1, b: 2, c: 3})
      refute subject.match?({b: 2, c: 3, d: :lol})
      refute subject.match?({a: 1, c: 3, d: :lol})
    end
  end
end
