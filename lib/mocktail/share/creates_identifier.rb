module Mocktail
  class CreatesIdentifier
    def create(s, default: "identifier", max_length: 24)
      id = s.to_s.downcase.gsub(/[^\w\s]/, "").gsub(/^\d+/, "")[0...max_length].strip.gsub(/\s+/, "_")

      if id.empty?
        default
      else
        id
      end
    end
  end
end
