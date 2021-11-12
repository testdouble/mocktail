require "test_helper"

module Mocktail
  class StubReturnedNilTest < Minitest::Test
    def test_weird_stuff_this_value_does
      stubbing = UnsatisfiedStubbing.new
      subject = StubReturnedNil.new(stubbing)

      assert subject.was_returned_by_unsatisfied_stub?

      # It implements tap
      tapped_val = nil
      tapped_return = subject.tap { |t| tapped_val = t }
      assert_same tapped_val, subject
      assert_same tapped_return, subject

      # It responds to what nil responds to
      assert subject.respond_to?(:to_s)
      assert subject.respond_to?(:nil?)
      assert subject.respond_to?(:to_a)
      refute subject.respond_to?(:size)
    end
  end
end
