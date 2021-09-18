require "test_helper"

# Used to compare the sources easily with .source
require "method_source"

class DslTest < Minitest::Test
  # A number of methods are duplicated on Mocktail and Mocktail::DSL and
  # because you can't bind singleton methods to a module for mixin, this will
  # just do a quick test to make sure they don't fall out of date
  def test_ensure_implementation_matches_between_main_and_dsl
    [
      :stubs,
      :verify
    ].each do |method_name|
      mocktail_method = Mocktail.method(:stubs)
      dsl_method = Mocktail::DSL.instance_method(:stubs)

      mocktail_source = mocktail_method.source.gsub(/self\./, "").gsub(/\s+/, "")
      dsl_source = dsl_method.source.gsub(/\s+/, "")

      assert_equal dsl_source, mocktail_source
    end
  end
end
