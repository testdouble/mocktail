# typed: true

require "sorbet-runtime"
require "mocktail"

class Sherbet
  extend T::Sig

  sig { returns(T.nilable(Symbol)) }
  attr_reader :flavor

  def initialize
    @flavor = :orange
  end
end

sherbet = Mocktail.of_next(Sherbet)

puts sherbet.flavor
