module Mocktail::Matchers
  class Not < Base
    def self.matcher_name
      :not
    end

    def match?(actual)
      @expected != actual
    end
  end
end
