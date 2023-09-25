# typed: true

module Mocktail::Matchers
  class CaptorTest < TLDR
    extend T::Sig

    sig { void }
    def test_basic_captor
      captor = Captor.new

      refute captor.captured?
      assert_nil captor.value

      assert_equal :capture, Captor::Capture.matcher_name
      assert captor.capture.match?(42) # side effect!
      assert captor.captured?
      assert_equal 42, captor.value

      assert_equal "capture", captor.capture.inspect
    end
  end
end
