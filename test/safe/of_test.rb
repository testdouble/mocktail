require "test_helper"

class OfTest < Minitest::Test
  class Neato
    def is_neato?
      true
    end
  end

  def test_neato
    neato = Mocktail.of(Neato)

    assert_match(/^#<Mocktail of OfTest::Neato:0x[0-9a-f]+>$/, neato.inspect)
    assert_equal neato.inspect, neato.to_s
    assert neato.kind_of?(Neato) # standard:disable Style/ClassCheck
    assert neato.is_a?(Neato)
  end

  class Welp
    def to_s
      "¯\_(ツ)_/¯"
    end
  end

  def test_welp
    welp = Mocktail.of(Welp)

    assert_match(/^#<Mocktail of OfTest::Welp:0x[0-9a-f]+>$/, welp.inspect)

    assert_nil welp.to_s # <-- because user defined, it's now mocked too
  end
end
