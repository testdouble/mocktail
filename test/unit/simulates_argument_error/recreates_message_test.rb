# typed: true

require "test_helper"

module Mocktail
  class RecreatesMessageTest < Minitest::Test
    def setup
      @subject = RecreatesMessage.new
    end

    # We don't have to cover everything (for example, cases where no error
    # message is necessary), because this method is only ever invoked once we've
    # deemed an argument error to have taken place
    def test_no_arg_case
      assert_equal "wrong number of arguments (given 1, expected 0)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [1],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 2, expected 0)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [1, 2],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
    end

    def test_one_arg_case
      assert_equal "wrong number of arguments (given 0, expected 1)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a], required: [:a]),
          positional_args: [],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 2, expected 1)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a], required: [:a]),
          positional_args: [1, 2],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 2, expected 0..1)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a], optional: [:a]),
          positional_args: [1, 2],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
    end

    def test_two_arg_case
      assert_equal "wrong number of arguments (given 0, expected 2)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b], required: [:a, :b]),
          positional_args: [],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 1, expected 2)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b], required: [:a, :b]),
          positional_args: [1],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 1, expected 2..3)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b, :c], required: [:a, :b], optional: [:c]),
          positional_args: [1],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 3, expected 2)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b], required: [:a, :b]),
          positional_args: [1, 2, 3],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
    end

    def test_args_with_kwargs
      assert_equal "wrong number of arguments (given 0, expected 1; required keywords: a, b)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a], required: [:a]),
          positional_args: [],
          keyword_params: Params.new(all: [:a, :b], required: [:a, :b]),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 1, expected 0; required keywords: a, b)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [1],
          keyword_params: Params.new(all: [:a, :b], required: [:a, :b]),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 1, expected 0; required keywords: a, b)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [1],
          keyword_params: Params.new(all: [:a, :b], required: [:a, :b]),
          keyword_args: {a: 1}
        ))
      assert_equal "wrong number of arguments (given 1, expected 0; required keyword: a)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [1],
          keyword_params: Params.new(all: [:a], required: [:a]),
          keyword_args: {a: 1, b: 2}
        ))
    end

    def test_only_kwarg_case
      assert_equal "missing keyword: :a",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [:a], required: [:a]),
          keyword_args: {}
        ))
      assert_equal "missing keyword: :a",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [:a], required: [:a]),
          keyword_args: {b: 4}
        ))
      assert_equal "missing keywords: :a, :b",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [:a, :b], required: [:a, :b]),
          keyword_args: {}
        ))
      assert_equal "unknown keyword: :b",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [:a], optional: [:a]),
          keyword_args: {b: 42}
        ))
      assert_equal "unknown keywords: :b, :c",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [], optional: []),
          keyword_args: {b: 42, c: :lol}
        ))
    end

    def test_rest
      assert_equal "wrong number of arguments (given 0, expected 1+)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :c], required: [:a], rest: :c),
          positional_args: [],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 0, expected 2+)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b, :c], required: [:a, :b], rest: :c),
          positional_args: [],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
      assert_equal "wrong number of arguments (given 1, expected 2+)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a, :b, :c], required: [:a, :b], rest: :c),
          positional_args: [1],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
    end

    # This happening is almost certainly a bug in Mocktail
    # (thinking a call is bad but not knowing why)
    def test_unknown_cause
      assert_equal "unknown cause (this is probably a bug in Mocktail)",
        @subject.recreate(Signature.new(
          positional_params: Params.new(all: [:a], required: [:a]),
          positional_args: [1],
          keyword_params: Params.new(all: []),
          keyword_args: {}
        ))
    end
  end
end
