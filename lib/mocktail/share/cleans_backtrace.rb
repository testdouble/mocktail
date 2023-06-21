# typed: true

require "pathname"

module Mocktail
  class CleansBacktrace
    BASE_PATH = (Pathname.new(__FILE__) + "../../..").to_s

    def clean(error)
      raise error
    rescue => e
      e.tap do |e|
        e.set_backtrace(e.backtrace.drop_while { |frame|
          frame.start_with?(BASE_PATH, BASE_PATH) || frame.match?(/[\\|\/]sorbet-runtime.*[\\|\/]lib[\\|\/]types[\\|\/]private/)
        })
      end
    end
  end
end
