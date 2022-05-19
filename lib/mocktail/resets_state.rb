# typed: true
module Mocktail
  class ResetsState
    def reset
      TopShelf.instance.reset_current_thread!
      Mocktail.cabinet.reset!
      ValidatesArguments.enable!
    end
  end
end
