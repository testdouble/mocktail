# typed: true
module Mocktail
  class LogsCall
    def log(dry_call)
      Mocktail.cabinet.store_call(dry_call)
    end
  end
end
