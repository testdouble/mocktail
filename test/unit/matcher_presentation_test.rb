# typed: true

require "test_helper"

module Mocktail
  class MatcherPresentationTest < Minitest::Test
    def setup
      @subject = MatcherPresentation.new
    end

    def test_respond_to?
      assert @subject.respond_to?(:any)
      refute @subject.respond_to?(:nonsense)

      assert_raises(NoMethodError) { @subject.nonsense }
    end
  end
end
