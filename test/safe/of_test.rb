require "test_helper"

class OfTest < Minitest::Test
  include Mocktail::DSL

  class Neato
    def is_neato?
      true
    end
  end

  def test_neato
    neato = Mocktail.of(Neato)

    assert_match(/^#<Mocktail of OfTest::Neato:0x[0-9a-f]+>$/, neato.inspect)
    assert_equal neato.inspect, neato.to_s
    assert_match(/^#<Class for mocktail of OfTest::Neato:0x[0-9a-f]+>$/, neato.class.inspect)
    assert_equal neato.class.inspect, neato.class.to_s
    assert neato.kind_of?(Neato) # standard:disable Style/ClassCheck
    assert neato.is_a?(Neato)
  end

  class Welp
    def to_s
      "¯\_(ツ)_/¯"
    end

    def inspect
      "secret"
    end
  end

  def test_welp
    welp = Mocktail.of(Welp)

    assert_nil welp.to_s # <-- because user defined, it's now mocked too
    assert_nil welp.inspect # <-- because user defined, it's now mocked too
  end

  module NotAClass
    def some_method(cool:)
    end
  end

  def test_module
    not_a_class = Mocktail.of(NotAClass)

    assert_match(/^#<Mocktail of OfTest::NotAClass:0x[0-9a-f]+>$/, not_a_class.inspect)
    assert_equal not_a_class.inspect, not_a_class.to_s
    assert_match(/^#<Class including module for mocktail of OfTest::NotAClass:0x[0-9a-f]+>$/, not_a_class.class.inspect)
    assert_equal not_a_class.class.inspect, not_a_class.class.to_s
    assert not_a_class.kind_of?(NotAClass) # standard:disable Style/ClassCheck
    assert not_a_class.is_a?(NotAClass)

    # Since we use more classes than modules, quick check stubbing works on it

    stubs { not_a_class.some_method(cool: :party) }.with { "🎉" }

    assert_nil not_a_class.some_method(cool: :beans)
    assert_equal "🎉", not_a_class.some_method(cool: :party)
  end

  def test_not_a_module_or_a_class
    e = assert_raises(Mocktail::UnsupportedMocktail) { Mocktail.of(Object.new) }
    assert_equal <<~MSG.tr("\n", " "), e.message
      Mocktail.of() can only mix mocktail instances of modules and classes.
    MSG
  end
end
