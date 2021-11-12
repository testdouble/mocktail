require "test_helper"

module Mocktail::Matchers
  class ThatTest < Minitest::Test
    def test_basic_that
      subject = That.new { |arg| arg == 42 }

      assert_equal :that, That.matcher_name
      assert_equal "that {…}", subject.inspect
      assert subject.is_mocktail_matcher?
      assert subject.match?(42)
      refute subject.match?(43)
    end

    def test_blockless_that
      e = assert_raises(ArgumentError) { That.new }
      assert_equal "The `that` matcher must be passed a block (e.g. `that { |arg| … }`)", e.message
    end
  end
end
