require "minitest/autorun"
require "mocktail"

class AntitypeTest < Minitest::Test
  include Mocktail::DSL

  module Stuff
    def things(pants, shirts, sandals:)
    end
  end

  def test_mocking_modules
    stuff = Mocktail.of(Stuff)

    stubs(ignore_arity: true, ignore_extra_args: true) { stuff.things }.with { "things" }

    assert_equal "things", stuff.things(1, 2, sandals: 3)
  end

  def test_matchers
    stuff = Mocktail.of(Stuff)

    stubs { stuff.things(:zubon, :shatsu, sandals: false) }.with { "things" }

    assert_equal "things", stuff.things(:zubon, :shatsu, sandals: false)
  end

  def teardown
    Mocktail.reset
  end
end
