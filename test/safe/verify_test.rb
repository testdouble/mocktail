require "test_helper"

class VerifyTest < Minitest::Test
  include Mocktail::DSL

  class SendsEmail
    def send(to:, from: "noreply@example.com", subject: "Yo", body: "yo")
      raise "woah real email watch out"
    end

    def dont_send!
    end
  end

  def test_sends_email
    sends_email = Mocktail.of(SendsEmail)

    sends_email.send(to: "becky@example.com")
    sends_email.send(to: "jerry@example.com")

    # Nothing happens:
    verify { sends_email.send(to: "becky@example.com") }
    Mocktail.verify { sends_email.send(to: "becky@example.com") }

    e = assert_raises(Mocktail::VerificationError) {
      verify { sends_email.send(to: "jenn@example.com") }
    }
    assert_equal <<~MSG, e.message
      Expected mocktail of VerifyTest::SendsEmail#send to be called like:

        send(to: "jenn@example.com")

      But it was called differently 2 times:

        send(to: "becky@example.com")

        send(to: "jerry@example.com")

    MSG

    assert_raises(Mocktail::VerificationError) {
      verify { sends_email.send(to: "becky@example.com", subject: "Yo") }
    }
  end

  def test_stub_and_verify_called_on_same_method
    sends_email = Mocktail.of(SendsEmail)

    e = assert_raises(Mocktail::VerificationError) {
      verify { sends_email.dont_send! }
    }
    assert_equal <<~MSG, e.message
      Expected mocktail of VerifyTest::SendsEmail#dont_send! to be called like:

        dont_send!

      But it was never called.
    MSG
  end
end
