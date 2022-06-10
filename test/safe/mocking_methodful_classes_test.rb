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
end
