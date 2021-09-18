require_relative "mocktail/error"
require_relative "mocktail/declares_dry_class"
require_relative "mocktail/dsl"
require_relative "mocktail/ensures_imitation_support"
require_relative "mocktail/finds_satisfaction"
require_relative "mocktail/fulfills_stubbing"
require_relative "mocktail/handles_dry_call"
require_relative "mocktail/imitates_type"
require_relative "mocktail/logs_call"
require_relative "mocktail/makes_double"
require_relative "mocktail/records_demonstration"
require_relative "mocktail/registers_stubbing"
require_relative "mocktail/stores_mocktails"
require_relative "mocktail/validates_arguments"
require_relative "mocktail/value/double"
require_relative "mocktail/value/dry_call"
require_relative "mocktail/value/stubbing"
require_relative "mocktail/version"

module Mocktail
  def self.of(type)
    ImitatesType.new.imitate(type)
  end

  def self.cabinet
    Thread.current[:mocktail_store] ||= StoresMocktails.new
  end
end
