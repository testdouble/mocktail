module Mocktail
  class InitializesMocktail
    def init
      [
        Mocktail::Matchers::Any,
        Mocktail::Matchers::Numeric,
        Mocktail::Matchers::IsA,
        Mocktail::Matchers::Matches,
        Mocktail::Matchers::Includes,
        Mocktail::Matchers::That
      ].each do |matcher_type|
        Mocktail.register_matcher(matcher_type)
      end
    end
  end
end
