require "test_helper"

class SimulatesArgumentErrorTest < Minitest::Test
  def setup
    @subject = Mocktail::SimulatesArgumentError.new
  end

  # We don't have to cover everything (for example, cases where no error
  # message is necessary), because this method is only ever invoked once we've
  # deemed an argument error to have taken place
  def test_no_arg_case
    assert_equal "wrong number of arguments (given 1, expected 0)", invoke([], [1], [], {})
    assert_equal "wrong number of arguments (given 2, expected 0)", invoke([], [1, 2], [], {})
    assert_equal "wrong number of arguments (given 1, expected 0)", invoke([], [{a: 1}], [], {})
    assert_equal "wrong number of arguments (given 1, expected 0)", invoke([], [{a: 1, b: 2}], [], {})
  end

  def test_one_arg_case
    assert_equal "wrong number of arguments (given 0, expected 1)", invoke([[:req, :a]], [], [], {})
    assert_equal "wrong number of arguments (given 2, expected 1)", invoke([[:req, :a]], [1, 2], [], {})
    assert_equal "wrong number of arguments (given 2, expected 0..1)", invoke([[:opt, :a]], [1, 2], [], {})
  end

  def test_two_arg_case
    assert_equal "wrong number of arguments (given 0, expected 2)", invoke([[:req, :a], [:req, :b]], [], [], {})
    assert_equal "wrong number of arguments (given 1, expected 2)", invoke([[:req, :a], [:req, :b]], [1], [], {})
    assert_equal "wrong number of arguments (given 1, expected 2..3)", invoke([[:req, :a], [:req, :b], [:opt, :c]], [1], [], {})
    assert_equal "wrong number of arguments (given 3, expected 2)", invoke([[:req, :a], [:req, :b]], [1, 2, 3], [], {})
  end

  def test_args_with_kwargs
    assert_equal "wrong number of arguments (given 0, expected 1; required keywords: a, b)", invoke([[:req, :a]], [], [[:keyreq, :a], [:keyreq, :b]], {})
    assert_equal "wrong number of arguments (given 1, expected 0; required keywords: a, b)", invoke([], [1], [[:keyreq, :a], [:keyreq, :b]], {})
    assert_equal "wrong number of arguments (given 1, expected 0; required keywords: a, b)", invoke([], [1], [[:keyreq, :a], [:keyreq, :b]], {a: 1})
    assert_equal "wrong number of arguments (given 1, expected 0; required keyword: a)", invoke([], [1], [[:keyreq, :a]], {a: 1, b: 2})
  end

  def test_only_kwarg_case
    assert_equal "missing keyword: :a", invoke([], [], [[:keyreq, :a]], {})
    assert_equal "missing keyword: :a", invoke([], [], [[:keyreq, :a]], {b: 4})
    assert_equal "missing keywords: :a, :b", invoke([], [], [[:keyreq, :a], [:keyreq, :b]], {})
  end

  def test_rest
    assert_equal "wrong number of arguments (given 0, expected 1+)", invoke([[:req, :a], [:rest, :c]], [], [], {})
    assert_equal "wrong number of arguments (given 0, expected 2+)", invoke([[:req, :a], [:req, :b], [:rest, :c]], [], [], {})
    assert_equal "wrong number of arguments (given 1, expected 2+)", invoke([[:req, :a], [:req, :b], [:rest, :c]], [1], [], {})
  end

  private

  def invoke(*args)
    @subject.simulate(*args).tap { |e|
      assert_kind_of ArgumentError, e
    }.message
  end
end
