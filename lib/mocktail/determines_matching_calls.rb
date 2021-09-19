module Mocktail
  class DeterminesMatchingCalls
    def determine(call, other)
      call.double == other.double &&
        call.method == other.method &&

        # Matcher implementation will replace this:
        call.args == other.args &&
        call.kwargs == other.kwargs &&
        call.blk == other.blk
    end
  end
end
