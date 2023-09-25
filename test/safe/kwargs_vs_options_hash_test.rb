# typed: strict

class KwargsVsOptionsHashTest < TLDR
  include Mocktail::DSL
  extend T::Sig

  class Charity
    extend T::Sig

    sig { params(amount: T.untyped).returns(T.untyped) }
    def donate(amount:)
      raise "Unimplemented"
    end

    sig { params(opts: T.untyped).returns(T.untyped) }
    def give(opts)
      raise "Unimplemented"
    end
  end

  sig { void }
  def test_handles_kwargs
    aclu = Mocktail.of(Charity)

    stubs { |m| aclu.donate(amount: m.numeric) }.with { :receipt }

    assert_equal :receipt, aclu.donate(amount: 100)
    assert_nil aclu.donate(amount: "money?")
  end

  sig { void }
  def test_handles_options_hashes
    wbc = Mocktail.of(Charity)

    stubs { wbc.give(to: "poor") }.with { :stringy_thanks }
    stubs { wbc.give({to: :poor}) }.with { :symbol_thanks }

    assert_equal :stringy_thanks, wbc.give(to: "poor")
    assert_equal :stringy_thanks, wbc.give({to: "poor"})
    assert_equal :symbol_thanks, wbc.give(to: :poor)
    assert_equal :symbol_thanks, wbc.give({to: :poor})
  end
end
