# typed: strict

require "bigdecimal"

module Mocktail::Matchers
  class NumericTest < TLDR
    extend T::Sig

    sig { void }
    def test_numeric_types
      subject = Numeric.new

      assert_equal :numeric, Numeric.matcher_name
      assert_equal "numeric", subject.inspect
      assert subject.is_mocktail_matcher?
      assert subject.match?(1)
      assert subject.match?(1.0)
      assert subject.match?(BigDecimal("1.0"))
      assert subject.match?(::Numeric.new)
      refute subject.match?("Hi")
      refute subject.match?(Integer)
      refute subject.match?(BigDecimal)
      refute subject.match?(::Numeric)
    end
  end
end
