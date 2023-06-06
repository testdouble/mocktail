# typed: false

module Mocktail
  class ValidatesArguments
    def self.disable!
      Thread.current[:mocktail_arity_validation_disabled] = true
    end

    def self.enable!
      Thread.current[:mocktail_arity_validation_disabled] = false
    end

    def self.disabled?
      Thread.current[:mocktail_arity_validation_disabled]
    end

    def self.optional(disable, &blk)
      return blk.call unless disable

      disable!
      blk.call.tap do
        enable!
      end
    end

    def initialize
      @simulates_argument_error = SimulatesArgumentError.new
    end

    def validate(dry_call)
      return if self.class.disabled?

      if (error = @simulates_argument_error.simulate(dry_call))
        raise error
      end
    end
  end
end
