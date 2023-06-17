# typed: true

require "test_helper"

class OfTest < Minitest::Test
  include Mocktail::DSL

  def teardown
    Mocktail.reset
  end

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
    assert neato.is_a?(Neato)
    assert neato.instance_of?(Neato)
    assert neato.kind_of?(Neato) # standard:disable Style/ClassCheck
  end

  class Welp
    def to_s
      "¯\\_(ツ)_/¯"
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
    not_a_class = SorbetOverride.disable_call_validation_checks do
      # This SEEMS not expressable in Sorbet
      # See: https://sorbet-ruby.slack.com/archives/CHN2L03NH/p1686331001121759
      T.unsafe(Mocktail).of(NotAClass)
    end

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
    e = SorbetOverride.disable_call_validation_checks do
      assert_raises(Mocktail::UnsupportedMocktail) { T.unsafe(Mocktail).of(Object.new) }
    end
    assert_equal <<~MSG.tr("\n", " "), e.message
      Mocktail.of() can only mix mocktail instances of modules and classes.
    MSG
  end

  class Wip
    def initialize
      raise "unimplemented!"
    end
  end

  class Argz
    def initialize(a, b:)
      raise "args required!"
    end
  end

  def test_ensures_fake_constructors
    assert Mocktail.of(Wip)
  end

  def test_constructors_dont_require_args
    assert Mocktail.of(Argz)
  end

  class Toolbox
    attr_accessor :hammer
  end

  def test_can_mock_attr_accessors
    toolbox = Mocktail.of(Toolbox)

    stubs { toolbox.hammer }.with { "🔨" }
    assert_equal "🔨", toolbox.hammer

    toolbox.hammer = "🔧"
    verify { toolbox.hammer = "🔧" }
  end
end
