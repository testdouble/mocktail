module Mocktail
  class StubReturnedNil < BasicObject
    attr_reader :unsatisfied_stubbing

    def initialize(unsatisfied_stubbing)
      @unsatisfied_stubbing = unsatisfied_stubbing
    end

    def was_returned_by_unsatisfied_stub?
      true
    end

    def tap
      yield self
      self
    end

    def method_missing(name, *args, **kwargs, &blk)
      nil.send(name, *args, **kwargs, &blk)
    end

    def respond_to_missing?(name, include_all = false)
      nil.respond_to?(name, include_all)
    end
  end
end
