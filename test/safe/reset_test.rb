# typed: strict

class ResetTest < TLDR
  include Mocktail::DSL
  extend T::Sig

  class Emailer
    extend T::Sig

    sig { returns(T.untyped) }
    def self.refresh
      "♻️"
    end

    sig { returns(T.untyped) }
    def email
      "📧"
    end
  end

  sig { void }
  def test_resetting_call_counts
    emailer = Mocktail.of(Emailer)
    verify(times: 0) { emailer.email }
    emailer.email
    verify(times: 1) { emailer.email }

    Mocktail.reset

    verify(times: 0) { emailer.email }
    emailer.email
    verify(times: 1) { emailer.email }
  end

  sig { void }
  def test_resetting_stubbings
    emailer = Mocktail.of(Emailer)
    assert_nil emailer.email
    stubs { emailer.email }.with { :email }
    assert_equal :email, emailer.email

    Mocktail.reset

    assert_nil emailer.email
    stubs { emailer.email }.with { :email }
    assert_equal :email, emailer.email
  end

  sig { void }
  def test_resetting_global_replacements
    Mocktail.replace(Emailer)
    assert_nil Emailer.refresh
    stubs { Emailer.refresh }.with { 0 }
    assert_equal 0, Emailer.refresh
    emailer = Emailer.new
    stubs { emailer.email }.with { "pants" }
    assert_equal "pants", emailer.email
    verify(times: 1) { Emailer.new }
    verify(times: 2) { Emailer.refresh }
    verify(times: 1) { emailer.email }
    of_next_emailers = Mocktail.of_next_with_count(Emailer, 2)
    assert_equal of_next_emailers.first, Emailer.new
    Mocktail::ValidatesArguments.disable! # YOLO
    assert Mocktail::ValidatesArguments.disabled?

    Mocktail.reset

    refute Mocktail::ValidatesArguments.disabled?
    post_reset_emailer = Emailer.new
    refute_equal of_next_emailers[1], post_reset_emailer
    # the class is of course just a class again
    assert_equal "♻️", Emailer.refresh
    assert_equal "📧", post_reset_emailer.email
    # the instance is still a valid-but-reset mock (b/c why not)
    verify(times: 0) { emailer.email }
    stubs { emailer.email }.with { "trousers" }
    assert_equal "trousers", emailer.email
  end
end
