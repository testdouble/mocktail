module Mocktail
  class FindsSatisfaction
    def find(dry_call)
      Mocktail.cabinet.stubbings.reverse.find { |stubbing|
        compare(dry_call, stubbing.recording)
      }
    end

    private

    def compare(dry_call, recording)
      dry_call.double == recording.double &&
        dry_call.method == recording.method &&

        # Matcher implementation will replace this:
        dry_call.args == recording.args &&
        dry_call.kwargs == recording.kwargs &&
        dry_call.blk == recording.blk
    end
  end
end
