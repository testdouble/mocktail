# typed: true

require "test_helper"

class MockingMethodfulClassesTest < Minitest::Test
  include Mocktail::DSL

  class OverridesEquals
    def normal_method
    end

    def ==(other)
      super
    end
  end

  def test_overriding_equals
    overrides_equals = Mocktail.of(OverridesEquals)

    overrides_equals.normal_method
    stubs { overrides_equals.normal_method }.with { 32 }

    assert_equal overrides_equals.normal_method, 32
  end

  class OverridesEverything
    (instance_methods - [:__send__, :object_id]).each do |method|
      define_method method, ->(*args, **kwargs, &block) {
        super
      }
    end

    def normal_method(arg = nil)
    end
  end

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
    assert_equal explanation.reference.stubbings[0].satisfaction_count, 1
    assert_equal explanation.reference.stubbings[1].satisfaction_count, 1
    assert_equal explanation.reference.stubbings[2].satisfaction_count, 1
  end

  def test_passing_mocks_and_comparing_them
    mock_1 = Mocktail.of(OverridesEverything)
    mock_2 = Mocktail.of(OverridesEverything)

    stubs { mock_1.normal_method(mock_2) }.with { :great_success }

    assert_equal mock_1.normal_method(mock_2), :great_success
  end
end
