# typed: strict

module Mocktail
  class TransformsParamsTest < TLDR
    extend T::Sig

    sig { void }
    def initialize
      @subject = T.let(TransformsParams.new, TransformsParams)
    end

    sig { void }
    def test_unnamed_args
      call = Call.new(
        original_method: Kernel.method(:puts)
      )

      result = @subject.transform(call)

      assert_equal [:unnamed_arg_1], result.positional_params.all
      assert_equal :unnamed_arg_1, result.positional_params.rest
    end

    sig { void }
    def test_multiple_args
      call = Call.new(
        original_method: Kernel.method(:autoload)
      )

      result = @subject.transform(call)

      assert_equal [:unnamed_arg_1, :unnamed_arg_2], result.positional_params.all
      assert_equal [:unnamed_arg_1, :unnamed_arg_2], result.positional_params.required
    end

    class Funk
      extend T::Sig

      sig { void }
      def initialize
        @bass = T.let(nil, T.untyped)
      end

      sig { params(bass: T.untyped).void }
      attr_writer :bass
    end

    sig { void }
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
