# typed: true

module Mocktail::Matchers
  class IncludesHash < Includes
    def self.matcher_name
      :includes_hash
    end
  end
end
