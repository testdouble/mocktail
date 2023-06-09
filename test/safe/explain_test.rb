# typed: true

require "test_helper"

class ExplainTest < Minitest::Test
  include Mocktail::DSL

  class Thing
    def do(arg = nil)
    end

    def dont_do
      raise "don't!"
    end
  end

  def test_explain_stub_returned_nil
    thing = Mocktail.of(Thing)
    thing.do

    explanations = Mocktail.explain_nils

    assert_equal 1, explanations.size
    explanation = explanations.first
    assert_kind_of Mocktail::UnsatisfyingCallExplanation, explanation
    assert_equal Mocktail::UnsatisfyingCallExplanation, explanation.type
    assert_equal <<~MSG, explanation.message
      `nil' was returned by a mocked `ExplainTest::Thing#do' method
      because none of its configured stubbings were satisfied.

      The actual call:

        do()

      The call site:

        #{__FILE__}:19:in `test_explain_stub_returned_nil'

      No stubbings were configured on this method.

    MSG
  end

  def test_explain_stub_returned_nil_with_stubbings
    thing = Mocktail.of(Thing)
    stubs { thing.do("pants") }.with { :ok }
    thing.do
    stubs { thing.do("too late of a stubbing") }.with { :ok }

    explanations = Mocktail.explain_nils

    assert_equal 1, explanations.size
    explanation = explanations.first
    assert_kind_of Mocktail::UnsatisfyingCallExplanation, explanation
    assert_equal Mocktail::UnsatisfyingCallExplanation, explanation.type
    # As for what's on this object, that's unspecified and may change. Don't rely on this!
    assert_kind_of Mocktail::UnsatisfyingCall, explanation.reference
    assert_equal <<~MSG, explanation.message
      `nil' was returned by a mocked `ExplainTest::Thing#do' method
      because none of its configured stubbings were satisfied.

      The actual call:

        do()

      The call site:

        #{__FILE__}:47:in `test_explain_stub_returned_nil_with_stubbings'

      Stubbings configured prior to this call but not satisfied by it:

        do("pants")

    MSG
  end

  def test_explain_nil
    a_nil = Thing.new.do

    explanation = Mocktail.explain(a_nil)

    assert_nil a_nil
    assert_kind_of Mocktail::NoExplanation, explanation
    assert_equal Mocktail::NoExplanation, explanation.type
    e1 = assert_raises(Mocktail::Error) { explanation.reference.calls }
    assert_equal "No calls have been recorded for nil, because Mocktail doesn't know what it is.", e1.message
    e2 = assert_raises(Mocktail::Error) { explanation.reference.stubbings }
    assert_equal "No stubbings exist on nil, because Mocktail doesn't know what it is.", e2.message

    ref = explanation.reference # Data type-specific data
    if ref.is_a?(Mocktail::NoExplanationData)
      assert_nil ref.thing
    end
    assert_equal <<~MSG.tr("\n", ""), explanation.message
      Unfortunately, Mocktail doesn't know what this thing is: nil
    MSG
  end

  def test_other_unknowns
    assert_kind_of Mocktail::NoExplanation, Mocktail.explain(Thing)
    assert_kind_of Mocktail::NoExplanation, Mocktail.explain(Thing.new)
    assert_kind_of Mocktail::NoExplanation, Mocktail.explain(Object.new)
    assert_kind_of Mocktail::NoExplanation, Mocktail.explain("hi")
  end

  def test_explain_double_instance
    thing = Mocktail.of(Thing)
    stubs { thing.do(42) }.with { :correct }
    thing.do("pants")
    thing.do

    explanation = Mocktail.explain(thing)

    assert_kind_of Mocktail::DoubleExplanation, explanation
    assert_equal Mocktail::DoubleExplanation, explanation.type
    # As for what's on this object, that's unspecified and may change. Don't rely on this!
    assert_kind_of Mocktail::DoubleData, explanation.reference

    assert_equal <<~MSG, explanation.message
      This is a fake `ExplainTest::Thing' instance.

      It has these mocked methods:
        - do
        - dont_do

      `ExplainTest::Thing#do' stubbings:

        do(42)

      `ExplainTest::Thing#do' calls:

        do("pants")

        do

      `ExplainTest::Thing#dont_do' has no stubbings.

      `ExplainTest::Thing#dont_do' has no calls.

    MSG
  end

  module Training
    def self.teach(people)
    end

    def self.learn!(thing)
    end
  end

  def test_explain_class_mocks
    Mocktail.replace(Training)
    stubs { Training.teach(:jerry) }.with { "🐾" }
    Training.learn!("🐈")
    Training.learn!(nil)

    explanation = Mocktail.explain(Training)

    assert_kind_of Mocktail::ReplacedTypeExplanation, explanation
    assert_equal Mocktail::ReplacedTypeExplanation, explanation.type
    # As for what's on this object, that's unspecified and may change. Don't rely on this!
    assert_kind_of Mocktail::TypeReplacementData, explanation.reference

    assert_equal <<~MSG, explanation.message
      `ExplainTest::Training' is a module that has had its singleton methods faked.

      It has these mocked methods:
        - learn!
        - teach

      `ExplainTest::Training.learn!' has no stubbings.

      `ExplainTest::Training.learn!' calls:

        learn!("🐈")

        learn!(nil)

      `ExplainTest::Training.teach' stubbings:

        teach(:jerry)

      `ExplainTest::Training.teach' has no calls.

    MSG
  end

  def test_explain_method_calls_on_instance
    thing = Mocktail.of(Thing)
    thing.do

    result = Mocktail.explain(thing.method(:do))

    assert_equal 1, Mocktail.explain(thing).reference.calls { |c| c.method == :do }.size
    assert_equal <<~MSG, result.message
      `ExplainTest::Thing#do' has no stubbings.

      `ExplainTest::Thing#do' calls:

        do
    MSG
    assert_equal [], result.reference.stubbings
    assert_equal 1, result.reference.calls.size

    ref = result.reference
    if ref.is_a?(Mocktail::FakeMethodData)
      assert_equal thing, ref.receiver
    end
  end

  def test_explain_method_calls_on_singleton
    Mocktail.replace(Training)
    stubs { Training.teach(:jerry) }.with { "🐾" }

    result = Mocktail.explain(Training.method(:teach))

    assert_equal 1, Mocktail.explain(Training).reference.stubbings { |c| c.method == :do }.size
    assert_equal <<~MSG, result.message
      `ExplainTest::Training.teach' stubbings:

        teach(:jerry)

      `ExplainTest::Training.teach' has no calls.
    MSG
    assert_equal 1, result.reference.stubbings.size
    assert_equal [], result.reference.calls
    ref = result.reference
    if ref.is_a?(Mocktail::FakeMethodData)
      assert_equal Training, ref.receiver
    end
  end
end
