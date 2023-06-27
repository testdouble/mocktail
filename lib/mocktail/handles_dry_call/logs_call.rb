module Mocktail
  class LogsCall
    extend T::Sig

    def log(dry_call)
      Mocktail.cabinet.store_call(dry_call)
    end
  end
end
