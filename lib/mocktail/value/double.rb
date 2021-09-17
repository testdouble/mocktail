module Mocktail
  class Double
    attr_reader :original_type, :dry_type, :dry_instance

    def initialize(original_type:, dry_type:, dry_instance:, calls: [])
      @original_type = original_type
      @dry_type = dry_type
      @dry_instance = dry_instance
      @calls = calls
    end
  end
end
