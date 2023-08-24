module Mocktail
  class CleansBacktrace
    extend T::Sig

    def clean(error)
      raise error
    rescue error.class => e
      e.tap do |e|
        e.set_backtrace(e.backtrace.drop_while { |frame|
          frame.start_with?(BASE_PATH, BASE_PATH) || frame.match?(/[\\|\/]sorbet-runtime.*[\\|\/]lib[\\|\/]types[\\|\/]private/)
        })
      end
    end
  end
end
