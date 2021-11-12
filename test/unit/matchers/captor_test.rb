require "test_helper"

module Mocktail::Matchers
  class CaptorTest < Minitest::Test
    def test_basic_captor
      captor = Captor.new

      refute captor.captured?
      assert_nil captor.value

      assert captor.capture.match?(42) # side effect!
      assert captor.captured?
      assert_equal 42, captor.value

      assert_equal "capture", captor.capture.inspect
    end
  end
end
