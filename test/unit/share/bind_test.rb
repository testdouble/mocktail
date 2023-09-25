# typed: strict

module Mocktail
  class BindTest < TLDR
    extend T::Sig

    class FortyTwo
      extend T::Sig

      sig { params(other: T.untyped).returns(T.untyped) }
      def ==(other)
        other == 42
      end

      sig { returns(T.untyped) }
      def self.ancestors
        [42, Integer, Numeric, Object]
      end
    end

    sig { void }
    def test_binds_if_thing_is_a_mock
      mock = Mocktail.of(FortyTwo)

      assert Bind.call(mock, :==, mock)
    end

    sig { void }
    def test_calls_through_if_thing_is_not_a_mock
      real = FortyTwo.new

      assert Bind.call(real, :==, 42) # <-- is what we want in practice
    end

    sig { void }
    def test_bind_calls_class_methods_if_faked
      Mocktail.replace(FortyTwo)

      assert_nil FortyTwo.ancestors
      assert_equal Bind.call(FortyTwo, :ancestors), [42, Integer, Numeric, Object]
    end
  end
end
