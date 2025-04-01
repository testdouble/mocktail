# typed: false

module VersionHelper
  def ruby_version
    Gem::Version.new(RUBY_VERSION)
  end

  def at_least_ruby_3_4?
    ruby_version >= "3.4"
  end
end
