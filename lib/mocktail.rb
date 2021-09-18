module Mocktail
  class Error < StandardError; end

  def self.of(type)
    ImitatesType.new.imitate(type)
  end

  def self.stubs(&demo) # .with {}
    RegistersStubbing.instance.register(demo)
  end

  def self.cabinet
    Thread.current[:mocktail_store] ||= Cabinet.new
  end
end

require_relative "mocktail/dsl"
require_relative "mocktail/imitates_type"
require_relative "mocktail/registers_stubbing"
require_relative "mocktail/value"
require_relative "mocktail/handles_dry_call"
require_relative "mocktail/version"
