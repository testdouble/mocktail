module Mocktail
  class Error < StandardError; end

  def self.of(type)
    ImitatesType.new.imitate(type)
  end

  def self.stubs(&demo)
    RegistersStubbing.instance.register(demo)
  end

  def self.verify(&demo)
    VerifiesCall.instance.verify(demo)
  end

  def self.captor
    Matchers::Captor.new
  end

  def self.matchers
    MatcherPresentation.instance
  end

  def self.register_matcher(matcher)
    RegistersMatcher.instance.register(matcher)
  end

  def self.cabinet
    Thread.current[:mocktail_store] ||= Cabinet.new
  end
end

require_relative "mocktail/dsl"
require_relative "mocktail/handles_dry_call"
require_relative "mocktail/imitates_type"
require_relative "mocktail/initializes_mocktail"
require_relative "mocktail/matcher_presentation"
require_relative "mocktail/matchers"
require_relative "mocktail/registers_matcher"
require_relative "mocktail/registers_stubbing"
require_relative "mocktail/value"
require_relative "mocktail/verifies_call"
require_relative "mocktail/version"

Mocktail::InitializesMocktail.new.init
