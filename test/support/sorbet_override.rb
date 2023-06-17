# Override Sorbet's runtime checks inside a given block's execution to allow
# testing of, among other things, Mocktail's own runtime type checks.
# See doc: https://sorbet.org/docs/tconfiguration
#
# Note that the messages being raised are the same as those constructed in
# sorbet-runtime (0.5.10847)
#
# Example usage:
# def test_not_a_class
#   e = SorbetOverride.disable_call_validation_checks do
#     assert_raises(Mocktail::UnsupportedMocktail) { T.unsafe(Mocktail).of_next(AModule) }
#   end
#   # …
# end
module SorbetOverride
  class RuntimeCheckConfig < T::Struct
    prop :inline_type, T::Boolean, default: true
    prop :call_validation, T::Boolean, default: true
    prop :sig_builder, T::Boolean, default: true
  end
  RUNTIME_CHECK_CONFIG = RuntimeCheckConfig.new

  def self.disable_inline_type_checks(&blk)
    RUNTIME_CHECK_CONFIG.inline_type = false
    ret = blk.call
    RUNTIME_CHECK_CONFIG.inline_type = true
    ret
  end

  def self.disable_call_validation_checks(&blk)
    RUNTIME_CHECK_CONFIG.call_validation = false
    ret = blk.call
    RUNTIME_CHECK_CONFIG.call_validation = true
    ret
  end

  def self.disable_sig_builder_checks(&blk)
    RUNTIME_CHECK_CONFIG.sig_builder = false
    ret = blk.call
    RUNTIME_CHECK_CONFIG.sig_builder = true
    ret
  end

  T::Configuration.inline_type_error_handler = lambda do |error, opts|
    if RUNTIME_CHECK_CONFIG.inline_type
      raise error
    elsif ENV["DEBUG"]
      puts "Sorbet inline_type_error_handler: #{error}"
      puts error.backtrace.join("\n")
    end
  end

  T::Configuration.call_validation_error_handler = lambda do |signature, opts|
    message = TypeError.new(opts[:pretty_message])
    if RUNTIME_CHECK_CONFIG.call_validation
      raise message
    elsif ENV["DEBUG"]
      puts "call_validation_error_handler: #{message}"
    end
  end

  T::Configuration.sig_builder_error_handler = lambda do |error, location|
    message = "#{location.path}:#{location.lineno}: Error interpreting `sig`:\n  #{error.message}\n\n"
    if RUNTIME_CHECK_CONFIG.sig_builder
      raise ArgumentError.new(message)
    elsif ENV["DEBUG"]
      puts "Sorbet sig_builder_error_handler: #{message}"
    end
  end
end
