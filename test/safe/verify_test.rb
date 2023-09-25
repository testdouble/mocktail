# typed: strict

class VerifyTest < TLDR
  include Mocktail::DSL
  extend T::Sig

  class SendsEmail
    extend T::Sig

    sig { params(to: T.untyped, from: T.untyped, subject: T.untyped, body: T.untyped).returns(T.untyped) }
    def send(to:, from: "noreply@example.com", subject: "Yo", body: "yo")
      raise "woah real email watch out"
    end

    sig { returns(T.untyped) }
    def dont_send!
    end
  end

  sig { void }
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
      Expected mocktail of `VerifyTest::SendsEmail#send' to be called like:

        send(to: "jenn@example.com")

      It was called differently 2 times:

        send(to: "becky@example.com")

        send(to: "jerry@example.com")

    MSG

    assert_raises(Mocktail::VerificationError) {
      verify { sends_email.send(to: "becky@example.com", subject: "Yo") }
    }
  end

  sig { void }
  def test_stub_and_verify_called_on_same_method
    sends_email = Mocktail.of(SendsEmail)

    e = assert_raises(Mocktail::VerificationError) {
      verify { sends_email.dont_send! }
    }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::SendsEmail#dont_send!' to be called like:

        dont_send!

      But it was never called.
    MSG
  end

  class Syn
    extend T::Sig

    sig { params(a: T.untyped, b: T.untyped, c: T.untyped).returns(T.untyped) }
    def ack(a = nil, b: nil, &c)
      raise "not real"
    end
  end

  sig { void }
  def test_matchers_and_kwargs
    syn = Mocktail.of(Syn)

    syn.ack(42, b: 1337)

    # Satisfied
    verify { |m| syn.ack(m.that { |a| a.even? }, b: m.that { |b| b.odd? }) }
    e = assert_raises(Mocktail::VerificationError) {
      verify { |m| syn.ack(m.that { |a| a.odd? }, b: m.that { |b| b.even? }) }
    }
    # It's a bummer we can't easily print the proc source inline, but important
    # to note that verifications blow up at verify()-time, so it won't be a
    # mystery for very long when the user looks at the error's line number
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack(that {…}, b: that {…})

      It was called differently 1 time:

        ack(42, b: 1337)

    MSG
  end

  sig { void }
  def test_blocks
    syn = Mocktail.of(Syn)

    syn.ack(:apple, b: :banana) { :orange }
    syn.ack(:apple, b: :banana) { :grape }

    # Satisfied
    verify { |m| syn.ack(:apple, b: :banana) { true } }
    verify { |m| syn.ack(:apple, b: :banana) { |real_blk| real_blk.call == :orange } }

    e = assert_raises(Mocktail::VerificationError) {
      verify { |m| syn.ack(:apple, b: :banana) { |real_blk| real_blk.call == :papaya } }
    }
    # It is indeed very frustrating how little introspection I can do of these blocks…
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack(:apple, b: :banana) { Proc at test/safe/verify_test.rb:115 }

      It was called differently 2 times:

        ack(:apple, b: :banana) { Proc at test/safe/verify_test.rb:107 }

        ack(:apple, b: :banana) { Proc at test/safe/verify_test.rb:108 }

    MSG
  end

  sig { void }
  def test_block_is_literally_an_identical_reference
    syn = Mocktail.of(Syn)
    a_lambda = lambda { raise "lol" }

    syn.ack(&a_lambda)

    # Should pass b/c it's the exact same lambda
    verify { syn.ack(&a_lambda) }
  end

  sig { void }
  def test_uses_a_captor_for_a_complex_arg
    syn = Mocktail.of(Syn)
    # imagine we don't care about b, c, or d
    complex_arg = {a: 1, b: 2, c: 3, d: 4}

    T.unsafe(syn).ack(complex_arg)

    captor = Mocktail.captor
    refute captor.captured?
    verify { syn.ack(captor.capture) }
    assert_equal 1, captor.value[:a]
    assert captor.captured?
  end

  sig { void }
  def test_verify_that_ignores_unspecified_blocks
    syn = Mocktail.of(Syn)

    syn.ack(42) { "i'm a block" }

    assert_raises(Mocktail::VerificationError) { verify { |m| syn.ack(m.numeric) } }
    verify(ignore_block: true) { |m| syn.ack(m.numeric) }
    e = assert_raises(Mocktail::VerificationError) {
      verify(ignore_block: true) { |m| syn.ack(1337) }
    }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack(1337) [ignoring blocks]

      It was called differently 1 time:

        ack(42) { Proc at test/safe/verify_test.rb:162 }

    MSG
  end

  sig { void }
  def test_verify_that_ignores_unspecified_args
    syn = Mocktail.of(Syn)

    syn.ack(:a)

    assert_raises(Mocktail::VerificationError) { verify { |m| syn.ack } }
    verify(ignore_extra_args: true) { |m| syn.ack }

    syn.ack(:pants, b: "cool")

    verify(ignore_extra_args: true) { |m| syn.ack(:pants) }
    e = assert_raises(Mocktail::VerificationError) {
      verify(ignore_extra_args: true) { |m| syn.ack(:trousers) }
    }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack(:trousers) [ignoring extra args]

      It was called differently 2 times:

        ack(:a)

        ack(:pants, b: "cool")

    MSG

    syn.ack(:lol, b: :kek) { :heh }
    verify(ignore_block: true, ignore_extra_args: true) { syn.ack }
  end

  sig { void }
  def test_verify_is_called_exactly_n_times
    syn = Mocktail.of(Syn)

    e = assert_raises(Mocktail::VerificationError) { verify(times: 2) { syn.ack } }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack [2 times]

      But it was never called this way.
    MSG

    syn.ack

    e = assert_raises(Mocktail::VerificationError) { verify(times: 2) { syn.ack } }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack [2 times]

      But it was actually called this way 1 time.
    MSG

    syn.ack

    # Finally satisfied
    verify(times: 2) { syn.ack }

    syn.ack(:a)
    syn.ack(:c)
    syn.ack

    e = assert_raises(Mocktail::VerificationError) { verify(times: 2) { syn.ack } }
    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::Syn#ack' to be called like:

        ack [2 times]

      But it was actually called this way 3 times.

      It was called differently 2 times:

        ack(:a)

        ack(:c)

    MSG
  end

  class EmailSender
    extend T::Sig

    sig { params(email: T.untyped).returns(T.untyped) }
    def self.send(email)
    end
  end

  sig { void }
  def test_replacing_classes
    Mocktail.replace(EmailSender)

    EmailSender.send(:a_email)

    e = assert_raises(Mocktail::VerificationError) {
      verify { EmailSender.send(:b_email) }
    }

    assert_equal <<~MSG, e.message
      Expected mocktail of `VerifyTest::EmailSender.send' to be called like:

        send(:b_email)

      It was called differently 1 time:

        send(:a_email)

    MSG
  end

  class Hmm
    extend T::Sig

    sig { params(idea: T.untyped).returns(T.untyped) }
    def huh(idea)
    end
  end

  sig { void }
  def test_verify_arg_hack
    hmm = Mocktail.of(Hmm)

    hmm.huh(:a)
    hmm.huh(:b)
    hmm.huh(:c)

    verify { |m| hmm.huh(:a) }
    verify { |m| hmm.huh(:b) }
    verify { |m| hmm.huh(:c) }
    verify(ignore_arity: true, ignore_extra_args: true) { |m| T.unsafe(hmm).huh }
  end
end
