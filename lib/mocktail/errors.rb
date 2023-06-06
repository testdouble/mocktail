# typed: false

module Mocktail
  class Error < StandardError; end

  class UnexpectedError < Error; end

  class UnsupportedMocktail < Error; end

  class MissingDemonstrationError < Error; end

  class AmbiguousDemonstrationError < Error; end

  class InvalidMatcherError < Error; end

  class VerificationError < Error; end
end
