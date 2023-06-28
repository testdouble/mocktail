require "test_helper"

class EnsureTypeSafetyTest < Minitest::Test
  def test_basic_case
    msg = assert_type_failure "\"foo\" + 1"

    assert_includes msg, "Expected `String` but found `Integer(1)`"
  end

  def test_strict_case
    msg = assert_strict_type_failure <<~RUBY
      def foo
        "no sig"
      end
    RUBY

    assert_includes msg, "The method `foo` does not have a `sig`"
  end
end
