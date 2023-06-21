# typed: true

require "test_helper"

module Mocktail
  class BindTest < Minitest::Test
    class FortyTwo
      def ==(other)
        other == 42
      end

      def self.ancestors
        [42, Integer, Numeric, BasicObject]
      end
    end

    def test_binds_if_thing_is_a_mock
      mock = Mocktail.of(FortyTwo)

      assert Bind.call(mock, :==, mock)
    end

    def test_calls_through_if_thing_is_not_a_mock
      real = FortyTwo.new

      assert Bind.call(real, :==, 42) # <-- is what we want in practice
    end

    def test_bind_calls_class_methods_if_faked
      Mocktail.replace(FortyTwo)

      assert_nil FortyTwo.ancestors
      assert_equal Bind.call(FortyTwo, :ancestors), [42, Integer, Numeric, BasicObject]
    end
  end
end
