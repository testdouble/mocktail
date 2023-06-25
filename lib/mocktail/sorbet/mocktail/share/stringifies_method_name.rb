# typed: strict

module Mocktail
  class StringifiesMethodName
    extend T::Sig

    sig { params(call: Call).returns(String) }
    def stringify(call)
      [
        call.original_type&.name,
        call.singleton ? "." : "#",
        call.method
      ].join
    end
  end
end
