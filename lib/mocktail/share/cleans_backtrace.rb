# typed: strict

require "pathname"

module Mocktail
  class CleansBacktrace
    extend T::Sig

    BASE_PATH = T.let((Pathname.new(__FILE__) + "../../..").to_s, String)

    sig {
      type_parameters(:T)
        .params(error: T.all(T.type_parameter(:T), StandardError))
        .returns(T.type_parameter(:T))
    }
    def clean(error)
      raise error
    rescue error.class => e
      T.cast(e, T.all(T.type_parameter(:T), StandardError)).tap do |e|
        e.set_backtrace(e.backtrace.drop_while { |frame|
          frame.start_with?(BASE_PATH, BASE_PATH) || frame.match?(/[\\|\/]sorbet-runtime.*[\\|\/]lib[\\|\/]types[\\|\/]private/)
        })
      end
    end
  end
end
