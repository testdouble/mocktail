require_relative "mocktail/declares_dry_class"
require_relative "mocktail/dsl"
require_relative "mocktail/fulfills_stubbing"
require_relative "mocktail/handles_dry_call"
require_relative "mocktail/logs_call"
require_relative "mocktail/makes_double"
require_relative "mocktail/stores_mocktails"
require_relative "mocktail/validates_arguments"
require_relative "mocktail/value/double"
require_relative "mocktail/value/dry_call"
require_relative "mocktail/version"

module Mocktail
  class Error < StandardError; end

  def self.of(klass)
    MakesDouble.new.make(klass).tap do |double|
      cabinet.store(double)
    end.dry_instance
  end

  def self.cabinet
    Thread.current[:mocktail_store] ||= StoresMocktails.new
  end
end
