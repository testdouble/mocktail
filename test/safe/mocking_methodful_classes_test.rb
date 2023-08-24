# typed: strict

require "test_helper"

class MockingMethodfulClassesTest < Minitest::Test
  include Mocktail::DSL
  extend T::Sig

  class OverridesEquals
    extend T::Sig

    sig { returns(T.untyped) }
    def normal_method
    end

    sig { params(other: T.untyped).returns(T.untyped) }
    def ==(other)
      super
    end
  end

  sig { void }
  def test_overriding_equals
    overrides_equals = Mocktail.of(OverridesEquals)

    overrides_equals.normal_method
    stubs { overrides_equals.normal_method }.with { 32 }

    assert_equal overrides_equals.normal_method, 32
  end

  class OverridesEverything
    extend T::Sig

    # puts instance_methods.map { |m| ":#{m}," }.join("\n")
    (instance_methods - [:__send__, :object_id, :nil?, :is_a?]).each do |method|
      define_method method, ->(*args, **kwargs, &block) {
        T.unsafe(self).super
      }
    end

    sig { params(arg: T.untyped).returns(T.untyped) }
    def normal_method(arg = nil)
    end
  end

  sig { void }
  def test_overriding_everything
    overrides_everything = Mocktail.of(OverridesEverything)
    overrides_everything.normal_method
    stubs { overrides_everything.normal_method }.with { 32 }
    stubs { |m| overrides_everything == m.any }.with { false }
    stubs { overrides_everything == 3 }.with { true }

    assert_equal overrides_everything.normal_method, 32
    assert_equal overrides_everything == 3, true
    assert_equal overrides_everything == 2, false
    verify { overrides_everything.normal_method }
    verify { overrides_everything == 3 }
    verify(times: 0) { overrides_everything == 4 }
    explanation = Mocktail.explain(overrides_everything)

    stubbings = explanation.reference.stubbings
    assert_equal stubbings[0]&.satisfaction_count, 1
    assert_equal stubbings[1]&.satisfaction_count, 1
    assert_equal stubbings[2]&.satisfaction_count, 1
  end

  sig { void }
  def test_passing_mocks_and_comparing_them
    mock_1 = Mocktail.of(OverridesEverything)
    mock_2 = Mocktail.of(OverridesEverything)

    stubs { mock_1.normal_method(mock_2) }.with { :great_success }

    assert_equal mock_1.normal_method(mock_2), :great_success
  end

  class OverridesNil
    extend T::Sig

    sig { returns(T.untyped) }
    def nil?
      false
    end
  end

  sig { void }
  def test_overrides_nil?
    skip "Can't quite figure out how to fix this"
    # This fails because when an attribute is set to a T::Struct that overrides
    # `nil?` (and just returns `nil?`), this check here kicks off an infinite
    # recursion:
    #
    # https://github.com/sorbet/sorbet/blob/master/gems/sorbet-runtime/lib/types/props/private/setter_factory.rb#L116
    overrides_nil = Mocktail.of(OverridesNil)

    overrides_nil.nil?
  end
end
