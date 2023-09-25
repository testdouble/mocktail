# typed: strict

module Mocktail
  class ReconcilesArgsWithParamsTest < TLDR
    extend T::Sig

    sig { void }
    def initialize
      @subject = T.let(ReconcilesArgsWithParams.new, ReconcilesArgsWithParams)
    end

    sig { void }
    def test_ensure_unknown_keyword_fails
      assert_equal false, @subject.reconcile(
        Signature.new(
          positional_params: Params.new(all: []),
          positional_args: [],
          keyword_params: Params.new(all: [:a], optional: [:a]),
          keyword_args: {b: 42}
        )
      )
    end
  end
end
