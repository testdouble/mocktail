# typed: true

require "sorbet-runtime"

require_relative "mocktail/collects_calls"
require_relative "mocktail/debug"
require_relative "mocktail/dsl"
require_relative "mocktail/errors"
require_relative "mocktail/explains_thing"
require_relative "mocktail/explains_nils"
require_relative "mocktail/grabs_original_method_parameters"
require_relative "mocktail/handles_dry_call"
require_relative "mocktail/handles_dry_new_call"
require_relative "mocktail/imitates_type"
require_relative "mocktail/initializes_mocktail"
require_relative "mocktail/matcher_presentation"
require_relative "mocktail/matchers"
require_relative "mocktail/raises_neato_no_method_error"
require_relative "mocktail/registers_matcher"
require_relative "mocktail/registers_stubbing"
require_relative "mocktail/replaces_next"
require_relative "mocktail/replaces_type"
require_relative "mocktail/resets_state"
require_relative "mocktail/simulates_argument_error"
require_relative "mocktail/stringifies_method_signature"
require_relative "mocktail/value"
require_relative "mocktail/verifies_call"
require_relative "mocktail/version"

module Mocktail
  extend T::Sig
  extend DSL

  # Returns an instance of `type` whose implementation is mocked out
  sig {
    type_parameters(:T)
      .params(type: T::Class[T.type_parameter(:T)])
      .returns(T.type_parameter(:T))
  }
  def self.of(type)
    ImitatesType.new.imitate(type)
  end

  # Returns an instance of `klass` whose implementation is mocked out AND
  # stubs its constructor to return that fake the next time klass.new is called
  sig {
    type_parameters(:T)
      .params(type: T::Class[T.type_parameter(:T)], count: T.nilable(Integer))
      .returns(T.type_parameter(:T))
  }
  def self.of_next(type, count: 1)
    ReplacesNext.new.replace(type, count)
  end

  # An alias of of_next that always returns an array of fakes
  sig {
    type_parameters(:T)
      .params(type: T::Class[T.type_parameter(:T)], count: T.nilable(Integer))
      .returns(T::Array[T.type_parameter(:T)])
  }
  def self.of_next_with_count(type, count:)
    Array(of_next(type, count: count))
  end

  sig { returns(Mocktail::MatcherPresentation) }
  def self.matchers
    MatcherPresentation.new
  end

  sig { returns(Mocktail::Matchers::Captor) }
  def self.captor
    Matchers::Captor.new
  end

  sig { params(matcher: T.class_of(Mocktail::Matchers::Base)).void }
  def self.register_matcher(matcher)
    RegistersMatcher.new.register(matcher)
  end

  # Replaces every singleton method on `type` with a fake, and when instantiated
  # or included will also fake instance methods
  sig { params(type: T.any(Class, Module)).void }
  def self.replace(type)
    ReplacesType.new.replace(type)
    nil
  end

  sig { void }
  def self.reset
    ResetsState.new.reset
  end

  sig {
    type_parameters(:T)
      .params(thing: T.type_parameter(:T))
      .returns(Explanation)
  }
  def self.explain(thing)
    ExplainsThing.new.explain(thing)
  end

  sig { returns(T::Array[Mocktail::UnsatisfyingCallExplanation]) }
  def self.explain_nils
    ExplainsNils.new.explain
  end

  # An alias for Mocktail.explain(double).reference.calls
  # Takes an optional second parameter of the method name to filter only
  # calls to that method
  sig {
    params(double: T.anything, method_name: T.nilable(T.any(String, Symbol)))
      .returns(T::Array[Mocktail::Call])
  }
  def self.calls(double, method_name = nil)
    CollectsCalls.new.collect(double, method_name)
  end

  # Stores most transactional state about calls & stubbing configurations
  # Anything returned by this is undocumented and could change at any time, so
  # don't commit code that relies on it!
  def self.cabinet
    Thread.current[:mocktail_store] ||= Cabinet.new
  end
end

Mocktail::InitializesMocktail.new.init
