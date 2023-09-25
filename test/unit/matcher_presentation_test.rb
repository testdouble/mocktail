# typed: strict

module Mocktail
  class MatcherPresentationTest < TLDR
    extend T::Sig

    sig { void }
    def initialize
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
