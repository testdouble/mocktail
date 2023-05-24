# typed: true

require "test_helper"

class KwargsVsOptionsHashTest < Minitest::Test
  include Mocktail::DSL

  class Charity
    def donate(amount:)
      raise "Unimplemented"
    end

    def give(opts)
      raise "Unimplemented"
    end
  end

  def test_handles_kwargs
    aclu = Mocktail.of(Charity)

    stubs { |m| aclu.donate(amount: m.numeric) }.with { :receipt }

    assert_equal :receipt, aclu.donate(amount: 100)
    assert_nil aclu.donate(amount: "money?")
  end

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
