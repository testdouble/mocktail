module Mocktail::Matchers
  class That < Base
    extend T::Sig

    sig { returns(Symbol) }
    def self.matcher_name
      :that
    end

    sig { params(blk: T.nilable(T.proc.params(actual: T.untyped).returns(T.untyped))).void }
    def initialize(&blk)
      if blk.nil?
        raise ArgumentError.new("The `that` matcher must be passed a block (e.g. `that { |arg| … }`)")
      end
      @blk = T.let(blk, T.proc.params(actual: T.untyped).returns(T.untyped))
    end

    sig { params(actual: T.untyped).returns(T::Boolean) }
    def match?(actual)
      @blk.call(actual)
    rescue
      false
    end

    sig { returns(String) }
    def inspect
      "that {…}"
    end
  end
end
