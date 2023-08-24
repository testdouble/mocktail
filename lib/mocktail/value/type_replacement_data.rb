module Mocktail
  class TypeReplacementData < T::Struct
    extend T::Sig

    const :type
    const :replaced_method_names
    const :calls
    const :stubbings

    include ExplanationData

    def double
      type
    end
  end
end
