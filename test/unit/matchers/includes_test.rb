# typed: true

require "test_helper"

module Mocktail::Matchers
  class IncludesTest < Minitest::Test
    def test_includes_hash_is_an_alias
      assert_includes IncludesHash.ancestors, Includes
      assert_equal :includes_hash, IncludesHash.matcher_name
      assert_equal IncludesHash.instance_method(:match?), Includes.instance_method(:match?)
    end

    def test_includes_key_is_an_alias
      assert_includes IncludesKey.ancestors, Includes
      assert_equal :includes_key, IncludesKey.matcher_name
      assert_equal IncludesKey.instance_method(:match?), Includes.instance_method(:match?)
    end

    def test_includes_string_is_an_alias
      assert_includes IncludesString.ancestors, Includes
      assert_equal :includes_string, IncludesString.matcher_name
      assert_equal IncludesString.instance_method(:match?), Includes.instance_method(:match?)
    end

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
