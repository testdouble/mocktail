require "test_helper"

class StubTest < Minitest::Test
  include Mocktail::DSL

  class GetsReminders
    def get(user_id)
    end
  end

  def test_gets_reminders
    gets_reminders = Mocktail.of(GetsReminders)

    stubs { gets_reminders.get(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], gets_reminders.get(42)
    assert_nil gets_reminders.get(41)
    assert_raises(ArgumentError) { gets_reminders.get }
    assert_raises(ArgumentError) { gets_reminders.get(4, 2) }
  end

  def test_non_dsl_is_also_fine
    gets_reminders = Mocktail.of(GetsReminders)

    Mocktail.stubs { gets_reminders.get(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], gets_reminders.get(42)
    assert_nil gets_reminders.get(41)
    assert_raises(ArgumentError) { gets_reminders.get }
    assert_raises(ArgumentError) { gets_reminders.get(4, 2) }
  end

  def test_multiple_calls_per_stub
    gets_reminders = Mocktail.of(GetsReminders)

    e = assert_raises(Mocktail::AmbiguousDemonstrationError) do
      stubs {
        gets_reminders.get(1)
        gets_reminders.get(2)
      }.with { [:r1, :r2] }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      `stubs` & `verify` expect exactly one invocation of a mocked method,
      but 2 were detected. As a result, Mocktail doesn't know which invocation
      to stub or verify.
    MSG
  end

  def test_zero_calls_per_stub
    gets_reminders = Mocktail.of(GetsReminders)

    e = assert_raises(Mocktail::MissingDemonstrationError) do
      stubs { gets_reminders }.with { [:r1, :r2] }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      `stubs` & `verify` expect an invocation of a mocked method by a passed
      block, but no invocation occurred.
    MSG
  end

  def test_forgets_the_with
    gets_reminders = Mocktail.of(GetsReminders)

    stubs { gets_reminders.get(42) }

    assert_nil gets_reminders.get(42)
  end

  class DoesTooMuch
    def do(this, that = nil, and:, also: "this", &block)
      raise "LOL"
    end
  end

  def test_param_checking
    does_too_much = Mocktail.of(DoesTooMuch)

    assert_raises(ArgumentError) { does_too_much.do }
    assert_raises(ArgumentError) { does_too_much.do { 1 } }
    assert_raises(ArgumentError) { does_too_much.do(1) }
    assert_raises(ArgumentError) { does_too_much.do(and: 1) }
    assert_raises(ArgumentError) { does_too_much.do(and: 1) { 2 } }
    assert_raises(ArgumentError) { does_too_much.do(1, 2) }
    assert_raises(ArgumentError) { does_too_much.do(1, 2, also: 3) }
    assert_raises(ArgumentError) { does_too_much.do(1, 2, also: 3) { 4 } }
    assert_raises(ArgumentError) { does_too_much.do(1, also: 3) }

    # Make sure it doesn't raise:
    does_too_much.do(1, and: 2)
    does_too_much.do(1, and: 2) { 3 }
    does_too_much.do(1, 2, and: 3)
    does_too_much.do(1, 2, and: 3, also: 4)
    does_too_much.do(1, 2, and: 3, also: 4) { 5 }
  end
end
