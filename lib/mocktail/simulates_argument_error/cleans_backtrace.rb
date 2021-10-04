module Mocktail
  class CleansBacktrace
    BASE_PATH = (Pathname.new(__FILE__) + "../../..").to_s

    def clean(error)
      raise error
    rescue => e
      e.tap do |e|
        e.set_backtrace(e.backtrace.drop_while { |frame|
          frame.start_with?(BASE_PATH)
        })
      end
    end
  end
end
