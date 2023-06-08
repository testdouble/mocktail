# typed: true

require "sorbet-runtime"
require "mocktail"
require "minitest/autorun"

require "tempfile"
require "open3"
module SorbetInsurance
  include Kernel

  def assert_type_failure(ruby_code, mode: "true")
    Tempfile.create do |file|
      file.write("# typed: strict\n\n" + ruby_code)
      file.flush
      stdout, stderr, status = Open3.capture3("bundle exec srb tc #{file.path}")
      raise "Type passing succeeded but expected failure (stdout: #{stdout})" if status.success?
      "#{stdout}\n#{stderr}"
    end
  end

  def assert_strict_type_failure(ruby_code)
    assert_type_failure(ruby_code, mode: "strict")
  end
end

class Minitest::Test
  include SorbetInsurance
  include Mocktail::DSL

  make_my_diffs_pretty!

  def teardown
    Mocktail.reset
  end
end
