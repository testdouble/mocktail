# typed: true
module Mocktail
  class CreatesIdentifier
    KEYWORDS = %w[__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield]

    def create(s, default: "identifier", max_length: 24)
      id = s.to_s.downcase
        .gsub(/:0x[0-9a-f]+/, "") # Lazy attempt to wipe any Object:0x802beef identifiers
        .gsub(/[^\w\s]/, "")
        .gsub(/^\d+/, "")[0...max_length]
        .strip
        .gsub(/\s+/, "_") # snake_case

      if id.empty?
        default
      else
        unreserved(id, default)
      end
    end

    private

    def unreserved(id, default)
      return id unless KEYWORDS.include?(id)

      "#{id}_#{default}"
    end
  end
end
