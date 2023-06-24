# typed: strict

require "test_helper"

module Mocktail
  class StringifiesCallTest < Minitest::Test
    extend T::Sig

    sig { params(name: String).void }
    def initialize(name)
      super

      @subject = T.let(StringifiesCall.new, StringifiesCall)
    end

    class DummyModule
      extend T::Sig

      sig { returns(T.untyped) }
      def self.lol
      end
    end

    sig { void }
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
      assert_equal "hi { Proc at test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:46 }", invoke {}
      assert_equal "hi(&lambda[test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:47])", invoke(&lambda {})

      # Mix & Match
      assert_equal "hi(:a, 1, b: 2) { Proc at test/unit/verifies_call/raises_verification_error/stringifies_call_test.rb:50 }", invoke(args: [:a, 1], kwargs: {b: 2}) { |c| 3 }
    end

    private

    sig { params(args: T::Array[T.untyped], kwargs: T::Hash[Symbol, T.untyped], block: T.untyped).returns(String) }
    def invoke(args: [], kwargs: {}, &block)
      @subject.stringify(Call.new(method: :hi, args: args, kwargs: kwargs, block: block))
    end
  end
end
