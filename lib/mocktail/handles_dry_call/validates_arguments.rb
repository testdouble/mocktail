# typed: strict

module Mocktail
  class ValidatesArguments
    extend T::Sig
    sig { void }
    def self.disable!
      Thread.current[:mocktail_arity_validation_disabled] = true
    end

    sig { void }
    def self.enable!
      Thread.current[:mocktail_arity_validation_disabled] = false
    end

    sig { returns(T::Boolean) }
    def self.disabled?
      !!Thread.current[:mocktail_arity_validation_disabled]
    end

    sig { params(disable: T.nilable(T::Boolean), blk: T.proc.returns(T.untyped)).void }
    def self.optional(disable, &blk)
      return blk.call unless disable

      disable!
      blk.call.tap do
        enable!
      end
    end

    sig { void }
    def initialize
      @simulates_argument_error = T.let(SimulatesArgumentError.new, Mocktail::SimulatesArgumentError)
    end

    sig { params(dry_call: T.untyped).returns(NilClass) }
    def validate(dry_call)
      return if self.class.disabled?

      if (error = @simulates_argument_error.simulate(dry_call))
        raise error
      end
    end
  end
end
