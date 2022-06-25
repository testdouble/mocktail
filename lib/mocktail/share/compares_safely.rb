module Mocktail
  class ComparesSafely
    def compare(thing, other_thing)
      Object.instance_method(:==).bind_call(thing, other_thing)
    end
  end
end
