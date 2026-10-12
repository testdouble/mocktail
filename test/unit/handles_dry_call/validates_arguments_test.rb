# typed: strict

require "test_helper"

module Mocktail
  class ValidatesArgumentsTest < Minitest::Test
    extend T::Sig

    sig { void }
    def test_optional_restores_validation_after_a_raise
      assert_raises(RuntimeError) { ValidatesArguments.optional(true) { raise "boom" } }

      refute ValidatesArguments.disabled?
    end

    sig { void }
    def test_optional_restores_validation_after_a_throw
      catch(:done) { ValidatesArguments.optional(true) { throw :done } }

      refute ValidatesArguments.disabled?
    end

    sig { void }
    def test_nested_optional_keeps_the_outer_scope_disabled
      disabled_after_inner = T.let(nil, T.untyped)

      ValidatesArguments.optional(true) do
        ValidatesArguments.optional(true) {}
        disabled_after_inner = ValidatesArguments.disabled?
      end

      assert_equal true, disabled_after_inner
      refute ValidatesArguments.disabled?
    end

    sig { void }
    def test_optional_restores_an_already_disabled_flag
      ValidatesArguments.disable!

      ValidatesArguments.optional(true) {}

      assert ValidatesArguments.disabled?
    end

    sig { void }
    def test_optional_leaves_the_flag_alone_when_not_disabling
      [false, nil].each do |disable|
        disabled_inside = T.let(nil, T.untyped)

        ValidatesArguments.optional(disable) { disabled_inside = ValidatesArguments.disabled? }

        assert_equal false, disabled_inside
        refute ValidatesArguments.disabled?
      end

      ValidatesArguments.disable!
      ValidatesArguments.optional(false) {}

      assert ValidatesArguments.disabled?
    end
  end
end
