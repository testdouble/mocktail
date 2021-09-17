require "test_helper"

class StubTest < Minitest::Test
  # Fixtures to play with
  class GetsReminders
    def get(user_id)
    end
  end

  class SummarizesReminders
    def summarize(reminders)
    end
  end

  class SendsAgenda
    def send(agenda)
    end
  end

  include Mocktail::DSL

  def test_gets_reminders
    gets_reminders = Mocktail.of(GetsReminders)

    stub { gets_reminders.get(42) }.with { [:r1, :r2] }

    assert_equal [:r1, :r2], gets_reminders(42)
    assert_nil gets_reminders(41)
    assert_raises(ArgumentError) { gets_reminders }
    assert_raises(ArgumentError) { gets_reminders(4, 2) }
  end

  # TODO blow up if multiple rehearsals happen inside stub {}
end
