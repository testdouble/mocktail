# typed: true

require "sorbet-runtime"
require "mocktail"

def assert_equal(expected, actual)
  raise "Expected #{expected} to equal #{actual}" unless expected == actual
end

class Sherbet
  extend T::Sig

  sig { returns(T.nilable(Symbol)) }
  attr_reader :flavor

  def initialize
    @flavor = :orange
  end
end

sherbet = Mocktail.of_next(Sherbet)
sherbets = Mocktail.of_next_with_count(Sherbet, count: 2)

assert_equal 2, sherbets.size

include Mocktail::DSL # standard:disable Style/MixinUsage

puts sherbet.flavor
