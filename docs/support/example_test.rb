require "mocktail"; require "minitest/autorun" # standard:disable Style/Semicolon

class PrepsFruitsTest < Minitest::Test
  def setup
    @fetches_fruits = Mocktail.of_next(FetchesFruits)
    @slices_fruit = Mocktail.of_next(SlicesFruit)
    @stores_fruit = Mocktail.of_next(StoresFruit)

    @subject = PrepsFruits.new
  end

def test_prep # standard:disable Layout/IndentationConsistency, Layout/IndentationWidth
  fruits = [Lime.new, Mango.new, Pineapple.new]
  stubs { @fetches_fruits.fetch([:lime, :mango, :pineapple]) }.with { fruits }
  stubs { |m| @slices_fruit.slice(m.is_a(Fruit)) }.with { |call|
    SlicedFruit.new(call.args.first)
  }
  stubs { |m| @stores_fruit.store(m.is_a(SlicedFruit)) }.with { |call|
    StoredFruit.new("ID for #{call.args.first.type}", call.args.first)
  }

  result = @subject.prep([:lime, :mango, :pineapple])

  assert_equal 3, result.size
  assert_equal "ID for Lime", result[0].id
  assert_equal Lime, result[0].fruit.type
  assert_equal "ID for Mango", result[1].id
  assert_equal Mango, result[1].fruit.type
  assert_equal "ID for Zebras", result[2].id
  assert_equal Pineapple, result[2].fruit.type
end
end

class PrepsFruits
  def initialize
    @fetches_fruits = FetchesFruits.new
    @slices_fruit = SlicesFruit.new
    @stores_fruit = StoresFruit.new
  end

  def prep(fruit_types)
    @fetches_fruits.fetch(fruit_types).map { |fruit|
      fruit = @slices_fruit.slice(fruit)
      @stores_fruit.store(fruit)
    }
  end
end

class FetchesFruits
  def fetch(types)
  end
end

class SlicesFruit
  def slice(fruit)
  end
end

class StoresFruit
  def store(fruit)
  end
end

class Fruit
end

class Lime < Fruit
end

class Mango < Fruit
end

class Pineapple < Fruit
end

class SlicedFruit
  def initialize(fruit)
    @fruit = fruit
  end

  def type
    @fruit.class
  end
end

StoredFruit = Struct.new(:id, :fruit)

class Minitest::Test
  include Mocktail::DSL

  def teardown
    Mocktail.reset
  end
end
