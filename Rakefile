require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

# Test against the (Sorbet-ful) source
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "src"
  ENV["MOCKTAIL_TEST_SRC_DIRECTORY"] = "src"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: [:test, "standard:fix"]
