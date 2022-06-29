require "test_helper"

module Mocktail
  class BuildsMethodSignatureTest < Minitest::Test
    def setup
      @subject = BuildsMethodSignature.new
    end

    def test_basic_call
      assert_equal @subject.build(signature), "()"
    end

    def test_positional_call
      assert_equal @subject.build(signature(
        positional_params: Params.new(all: [:a, :b], required: [:a, :b]),
      )),
     "(a, b)"
    end

    def test_optional_positional_call
      assert_equal @subject.build(signature(
        positional_params: Params.new(
          all: [:a, :b],
          required: [:b],
          optional: [:a]
        ),
      )),
     "(a = nil, b)"
    end

    def test_kwarg_call
      assert_equal @subject.build(signature(
        keyword_params: Params.new(
          all: [:a, :b],
          required: [:b],
          optional: [:a]
        ),
      )),
     "(a: nil, b:)"
    end

    def test_block_call
      assert_equal @subject.build(signature(
        block_param: [],
      )),
     "(&block)"
    end

    def test_rest_call
      assert_equal @subject.build(signature(
        positional_params: Params.new(all: [:args], rest: :args),
      )),
     "(*args)"
    end

    def test_kwrest_call
      assert_equal @subject.build(signature(
        keyword_params: Params.new(all: [:kwargs], rest: :kwargs),
      )),
     "(**kwargs)"
    end

    def test_complex_call
      assert_equal @subject.build(signature(
        positional_params: Params.new(all: [:a, :b, :args], required: [:a], optional: [:b], rest: :args),
        keyword_params: Params.new(all: [:c, :d, :kwargs], required: [:c], optional: [:d], rest: :kwargs),
        block_param: [:block],
      )),
     "(a, b = nil, *args, c:, d: nil, **kwargs, &block)"
    end

    def test_dotdotdot_call
      sig = TransformsParams.new.transform(
        Call.new,
        params: method(:dotdotdot).parameters
      )
      assert_equal @subject.build(sig), "(...)"
    end

    def test_dotdotdot_with_args_call
      sig = TransformsParams.new.transform(
        Call.new,
        params: method(:dotdotdot_with_args).parameters
      )
      assert_equal @subject.build(sig), "(a, b = nil, ...)"
    end

    def dotdotdot(...); end
    def dotdotdot_with_args(a, b = :foo, ...); end

    def signature(positional_params: Params.new(all: []), keyword_params: Params.new(all: []), block_param: false)
      Signature.new(
        positional_params: positional_params,
        positional_args: [],
        keyword_params: keyword_params,
        keyword_args: {},
        block_param: block_param,
        block_arg: nil
      )
    end
  end
end
