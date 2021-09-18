module Mocktail
  class Double
    attr_reader :original_type, :dry_type, :dry_instance

    def initialize(original_type:, dry_type:, dry_instance:)
      @original_type = original_type
      @dry_type = dry_type
      @dry_instance = dry_instance
    end
  end
end
