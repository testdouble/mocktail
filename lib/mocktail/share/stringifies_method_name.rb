module Mocktail
  class StringifiesMethodName
    def stringify(call)
      [
        call.original_type.name,
        call.singleton ? "." : "#",
        call.method
      ].join
    end
  end
end
