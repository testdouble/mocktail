# typed: strict

module Mocktail
  class LogsCall
    extend T::Sig

    sig { params(dry_call: Call).void }
    def log(dry_call)
      Mocktail.cabinet.store_call(dry_call)
    end
  end
end
