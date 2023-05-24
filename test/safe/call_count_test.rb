# typed: true

require "test_helper"

class CallCountTest < Minitest::Test
  include Mocktail::DSL

  class College
    def try(*args, **kwargs, &blk)
      raise "loans"
    end

    def graduate
      raise "grades"
    end
  end

  # calls(double) is a shorter alias for explain(mock).reference.calls
  def test_calls_overall
    college = Mocktail.of(College)
    assert_equal 0, Mocktail.calls(college).count

    college.try
    college.graduate

    assert_equal 2, Mocktail.calls(college).count
    assert_equal Mocktail.explain(college).reference.calls, Mocktail.calls(college)
  end

  # calls(double, method_name) will also filter the calls to the method name
  # This test is a bit overwrought, but want to define it in terms of an alias to
  # explain, so I'm just testing each permutation to ensure it's filtering methods
  def test_calls_for_a_method
    college = Mocktail.of(College)
    assert_equal 0, Mocktail.calls(college, :try).count

    college.try

    assert_equal 1, Mocktail.calls(college, :try).count
    assert_equal Mocktail.explain(college).reference.calls.first, Mocktail.calls(college, :try).first

    college.graduate

    assert_equal 1, Mocktail.calls(college, :graduate).count
    assert_equal [Mocktail.explain(college).reference.calls.last], Mocktail.calls(college, :graduate)
    assert_equal Mocktail.explain(college).reference.calls, Mocktail.calls(college, :try) + Mocktail.calls(college, :graduate)
  end

  class Admission
    def self.deny
      raise "nope"
    end

    def self.approve
      raise "nope"
    end
  end

  def test_class_methods
    Mocktail.replace(Admission)
    assert_equal 0, Mocktail.calls(Admission).count

    Admission.deny

    assert_equal 1, Mocktail.calls(Admission).count
    assert_equal 1, Mocktail.calls(Admission, :deny).count
    assert_equal 0, Mocktail.calls(Admission, :approve).count
  end
end
