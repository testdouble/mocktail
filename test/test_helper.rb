require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "mocktail"

require "minitest/autorun"

class Minitest::Test
  protected

  make_my_diffs_pretty!

  def thread(&blk)
    Thread.new(&blk).tap do |t|
      t.abort_on_exception = true
    end
  end
end
