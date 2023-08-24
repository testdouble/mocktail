# typed: strict

require "test_helper"

module Mocktail
  class MatcherPresentationTest < Minitest::Test
    extend T::Sig

    sig { params(name: String).void }
    def initialize(name)
      super

      @subject = T.let(MatcherPresentation.new, MatcherPresentation)
    end

    sig { void }
    def test_respond_to?
      assert @subject.respond_to?(:any)
      refute @subject.respond_to?(:nonsense)

      assert_raises(NoMethodError) { T.unsafe(@subject).nonsense }
    end
  end
end
