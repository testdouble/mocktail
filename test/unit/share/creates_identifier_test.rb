require "test_helper"

module Mocktail
  class CreatesIdentifierTest < Minitest::Test
    def setup
      @subject = CreatesIdentifier.new
    end

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

    def test_multi_word_identifier
      assert_equal "foo_bar", @subject.create("foo bar")
      assert_equal "foo_bar", @subject.create("foo  bar")
    end

    def test_invalid
      assert_equal "identifier", @subject.create(2)
      assert_equal "arg", @subject.create("2", default: "arg")

      # valid but being conservative
      assert_equal "identifier", @subject.create("ふう")
    end
  end
end
