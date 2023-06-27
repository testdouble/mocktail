module Mocktail::Matchers
  class Not < Base
    extend T::Sig

    def self.matcher_name
      :not
    end

    def match?(actual)
      @expected != actual
    end
  end
end
