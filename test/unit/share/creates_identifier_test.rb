# typed: strict

module Mocktail
  class CreatesIdentifierTest < TLDR
    extend T::Sig

    sig { void }
    def initialize
      @subject = T.let(CreatesIdentifier.new, CreatesIdentifier)
    end

    sig { void }
    def test_basic_identifier
      assert_equal "foo", @subject.create("foo")
      assert_equal "foo", @subject.create(:foo)
      assert_equal "foo", @subject.create("1foo")
      assert_equal "foo", @subject.create("1 foo")
      assert_equal "f1oo", @subject.create("f1oo")
      assert_equal "foo1", @subject.create("foo1")
      assert_equal "foo_2", @subject.create("foo 2")
      assert_equal "foo", @subject.create("FoO")
      assert_equal "i_am_a_super_duper_long", @subject.create("i am a super duper long argument please cut me off")
    end

    sig { void }
    def test_multi_word_identifier
      assert_equal "foo_bar", @subject.create("foo bar")
      assert_equal "foo_bar", @subject.create("foo  bar")
    end

    sig { void }
    def test_weird
      assert_equal "object", @subject.create(Object.new)
      assert_equal "class_identifier", @subject.create(Class.new)
      assert_equal "else_arg", @subject.create("else", default: "arg")
    end

    sig { void }
    def test_invalid
      assert_equal "identifier", @subject.create(2)
      assert_equal "arg", @subject.create("2", default: "arg")

      # valid but being conservative
      assert_equal "identifier", @subject.create("ふう")
    end
  end
end
