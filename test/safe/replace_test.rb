require "test_helper"

class ReplaceTest < Minitest::Test
  include Mocktail::DSL

  class House
    def self.room(room_name)
      raise "Unimplemented"
    end

    def self.size(uom:)
      raise "Unimplemented"
    end

    def self.summarize(title = nil, features: [], &tap)
      raise "Unimplemented"
    end

    def initialize(location)
      raise "Unimplemented"
    end

    def id
      raise "Unimplemented"
    end
  end

  def test_replace_class
    skip
    Mocktail.replace(House)

    # None of these call through, so none blow up
    House.room("living")
    House.size(uom: "ft")
    House.summarize("Madiera", features: [:walls, :floor]) { "🆒" }

    # Argument errors still propogate
    assert_raises(ArgumentError) { House.room(wrong: :arg) }
    assert_raises(ArgumentError) { House.size }
    assert_raises(ArgumentError) { House.summarize("title", "wups") }

    # verification works
    verify { House.room("living") }
    verify { |m| House.size(uom: m.is_a(String)) }
    verify { House.summarize("Madiera", features: m.includes(:walls, :floor)) { |real| real.call == "🆒" } }

    # stubbing works
    stubs { House.room("dining") }.with { "🍽" }
    stubs { House.size(uom: "m") }.with { "📏" }
    stubs { House.summarize }.with { "😶" }

    assert_equal "🍽", House.room("dining")
    assert_equal "📏", House.size(uom: "m")
    assert_equal "😶", House.summarize

    # new() does require proper params and can be verified
    assert_raises(ArgumentError) { House.new }
    house = House.new(:some_latlong)

    verify { House.new(:some_latlong) }
    verify { house.send(:initialize, :some_latlong) }

    other_house = House.new(:a_map)
    refute_same other_house, house

    stubs { house.id }.with { 4 }
    stubs { other_house.id }.with { 8 }

    assert_equal 4, house.id
    assert_equal 8, other_house.id
  end
end
