# typed: strict

require "simplecov"
SimpleCov.start do
  SimpleCov.add_filter "/test/"
end

ENV["MOCKTAIL_DEBUG_ACCIDENTAL_INTERNAL_MOCK_CALLS"] = "true"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "mocktail"
require "minitest/autorun"

require_relative "support/sorbet_override"

class Minitest::Test
  extend T::Sig

  protected

  make_my_diffs_pretty!

  sig { params(blk: T.proc.void).returns(Thread) }
  def thread(&blk)
    Thread.new(&blk).tap do |t|
      t.abort_on_exception = true
    end
  end

  sig { returns(T::Boolean) }
  def runtime_type_checking_disabled?
    T::Private::RuntimeLevels.default_checked_level == :never
  end

  sig { params(thing: T.anything).void }
  def assert_nil_or_void(thing)
    if runtime_type_checking_disabled?
      assert_nil(thing)
    else
      assert_same thing, T::Private::Types::Void::VOID
    end
  end

  sig { void }
  def teardown
    Mocktail.reset
  end
end
