require "test_helper"

module Mocktail
  class StringifiesMethodSignatureTest < Minitest::Test
    def setup
      @subject = StringifiesMethodSignature.new
    end

    def test_basic_call
      result = @subject.stringify(signature)

      assert_equal "(&blk)", result
    end

    def test_positional_call
      result = @subject.stringify(signature(
        positional_params: Params.new(all: [:a, :b], required: [:a, :b])
      ))

      assert_equal "(a = ((__mocktail_default_args ||= {})[:a] = nil), b = ((__mocktail_default_args ||= {})[:b] = nil), &blk)", result
    end

    def test_optional_positional_call
      result = @subject.stringify(signature(
        positional_params: Params.new(
          all: [:a, :b],
          required: [:b],
          optional: [:a]
        )
      ))

      assert_equal "(a = ((__mocktail_default_args ||= {})[:a] = nil), b = ((__mocktail_default_args ||= {})[:b] = nil), &blk)", result
    end

    def test_kwarg_call
      result = @subject.stringify(signature(
        keyword_params: Params.new(
          all: [:a, :b],
          required: [:b],
          optional: [:a]
        )
      ))

      assert_equal "(a: ((__mocktail_default_args ||= {})[:a] = nil), b: ((__mocktail_default_args ||= {})[:b] = nil), &blk)", result
    end

    def test_block_call
      result = @subject.stringify(signature(
        block_param: :blocky
      ))

      assert_equal "(&blocky)", result
    end

    def test_argless_call
      result = @subject.stringify(signature)

      assert_equal "(&blk)", result
    end

    def test_rest_call
      result = @subject.stringify(signature(
        positional_params: Params.new(all: [:args], rest: :args)
      ))

      assert_equal "(*args, &blk)", result
    end

    def test_kwrest_call
      result = @subject.stringify(signature(
        keyword_params: Params.new(all: [:kwargs], rest: :kwargs)
      ))

      assert_equal "(**kwargs, &blk)", result
    end

    def test_complex_call
      result = @subject.stringify(signature(
        positional_params: Params.new(all: [:a, :b, :args], required: [:a], optional: [:b], rest: :args),
        keyword_params: Params.new(all: [:c, :d, :kwargs], required: [:c], optional: [:d], rest: :kwargs),
        block_param: :block
      ))

      assert_equal "(a = ((__mocktail_default_args ||= {})[:a] = nil), b = ((__mocktail_default_args ||= {})[:b] = nil), *args, c: ((__mocktail_default_args ||= {})[:c] = nil), d: ((__mocktail_default_args ||= {})[:d] = nil), **kwargs, &block)", result
    end

    unless Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
      def dotdotdot(...)
      end

      def dotdotdot_with_args(a, b = :foo, ...)
      end
    end

    def test_dotdotdot_call
      skip if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
      signature = TransformsParams.new.transform(
        Call.new,
        params: method(:dotdotdot).parameters
      )

      result = @subject.stringify(signature)

      assert_equal "(*args, **kwargs, &blk)", result
    end

    def test_dotdotdot_with_args_call
      skip if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
      signature = TransformsParams.new.transform(
        Call.new,
        params: method(:dotdotdot_with_args).parameters
      )

      result = @subject.stringify(signature)

      assert_equal "(a = ((__mocktail_default_args ||= {})[:a] = nil), b = ((__mocktail_default_args ||= {})[:b] = nil), *args, **kwargs, &blk)", result
    end

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
