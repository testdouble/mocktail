module Mocktail
  class ResetsState
    extend T::Sig

    def reset
      TopShelf.instance.reset_current_thread!
      Mocktail.cabinet.reset!
      ValidatesArguments.enable!
    end
  end
end
