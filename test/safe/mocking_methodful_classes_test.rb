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

    def normal_method
    end
  end

  def test_overriding_everything
    overrides_everything = Mocktail.of(OverridesEverything)

    overrides_everything.normal_method
    stubs { overrides_everything.normal_method }.with { 32 }

    assert_equal overrides_everything.normal_method, 32
  end
end
