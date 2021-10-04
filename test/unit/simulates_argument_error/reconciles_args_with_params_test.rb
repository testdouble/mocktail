require "test_helper"

module Mocktail
  class ReconcilesArgsWithParamsTest < Minitest::Test
    def setup
      @subject = ReconcilesArgsWithParams.new
    end

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
