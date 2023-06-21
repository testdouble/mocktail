# typed: true

require "test_helper"

module Mocktail
  class TransformsParamsTest < Minitest::Test
    def setup
      @subject = TransformsParams.new
    end

    def test_unnamed_args
      call = Call.new(
        original_method: Kernel.method(:puts)
      )

      result = @subject.transform(call)

      assert_equal [:unnamed_arg_1], result.positional_params.all
      assert_equal :unnamed_arg_1, result.positional_params.rest
    end

    def test_multiple_args
      call = Call.new(
        original_method: Kernel.method(:autoload)
      )

      result = @subject.transform(call)

      assert_equal [:unnamed_arg_1, :unnamed_arg_2], result.positional_params.all
      assert_equal [:unnamed_arg_1, :unnamed_arg_2], result.positional_params.required
    end

    class Funk
      attr_writer :bass
    end

    def test_b
      call = Call.new(
        original_method: Funk.instance_method(:bass=)
      )

      result = @subject.transform(call)

      assert_equal [:unnamed_arg_1], result.positional_params.all
      assert_equal [:unnamed_arg_1], result.positional_params.required
    end
  end
end
