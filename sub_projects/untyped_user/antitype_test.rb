require "minitest/autorun"
require "mocktail"

class AntitypeTest < Minitest::Test
  module Stuff
    def things
    end
  end

  def test_mocking_modules
    stuff = Mocktail.of(Stuff)

    stubs { stuff.things }.with { "things" }

    assert_equal "things", stuff.things
  end

  def teardown
    Mocktail.reset
  end
end
