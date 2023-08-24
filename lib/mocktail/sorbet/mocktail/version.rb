# typed: strict

module Mocktail
  # The gemspec will define Module::VERSION as loaded from lib/, but if the
  # user loads mocktail/sorbet, its version file will be effectively redefining
  # it. Undef it first to ensure we don't spew warnings
  if defined?(VERSION)
    Mocktail.send(:remove_const, :VERSION)
  end

  VERSION = "1.2.3"
end
