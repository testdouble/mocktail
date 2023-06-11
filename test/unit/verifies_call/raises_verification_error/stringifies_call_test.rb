# typed: true

require "test_helper"

module Mocktail
  class StringifiesCallTest < Minitest::Test
    def setup
      @subject = StringifiesCall.new
    end

    class DummyModule
      def self.lol
      end
    end

    def test_some_calls
      # No args, no parens
      assert_equal "hi", invoke
      assert_equal "hi", invoke(args: [], kwargs: {})

      # Basic args
      assert_equal "hi(\"311\")", invoke(args: ["311"])
      assert_equal "hi(1, 2, \"3\")", invoke(args: [1, 2, "3"])
      assert_equal "hi([], [1], [[2]], [[3, 4], [5, 6]])", invoke(args: [
        [], [1], [[2]], [[3, 4], [5, 6]]
      ])
      assert_equal "hi({}, {:a=>1}, {:b=>2, :c=>3}, {:d=>[4, {:e=>5}]})", invoke(args: [
        {}, {a: 1}, {b: 2, c: 3}, {d: [4, {e: 5}]}
      ])

      # Kwargs
      assert_equal "hi(a: 1)", invoke(kwargs: {a: 1})
      assert_equal "hi(c: 2, b: 3)", invoke(kwargs: {c: 2, b: 3})
      assert_equal "hi(d: {:e=>4}, f: [:g, {:h=>5}])", invoke(kwargs: {d: {e: 4}, f: [:g, {h: 5}]})

      # Blocks & Procs
      assert_equal "hi { Proc at test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:37 }", invoke {}
      assert_equal "hi(&lambda[test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:12])", invoke(&DummyModule.method(:lol))

      # Mix & Match
      assert_equal "hi(:a, 1, b: 2) { Proc at test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:41 }", invoke(args: [:a, 1], kwargs: {b: 2}) { |c| 3 }
    end

    private

    def invoke(args: [], kwargs: {}, &block)
      @subject.stringify(Call.new(method: :hi, args: args, kwargs: kwargs, block: block))
    end
  end
end
