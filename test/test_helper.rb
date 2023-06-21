# typed: true

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
  protected

  make_my_diffs_pretty!

  def thread(&blk)
    Thread.new(&blk).tap do |t|
      t.abort_on_exception = true
    end
  end

  def assert_nil_or_void(thing)
    if T::Private::RuntimeLevels.default_checked_level == :never
      assert_nil(thing)
    else
      assert_same thing, T::Private::Types::Void::VOID
    end
  end

  def teardown
    Mocktail.reset
  end
end
