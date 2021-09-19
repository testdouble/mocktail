module Mocktail::Matchers
  class That < Base
    def self.matcher_name
      :that
    end

    def initialize(&blk)
      if blk.nil?
        raise "The `that` matcher must be passed a block (e.g. `that { |arg| … }`)"
      end
      @blk = blk
    end

    def match?(actual)
      @blk.call(actual)
    end

    def inspect
      "that {…}"
    end
  end
end
