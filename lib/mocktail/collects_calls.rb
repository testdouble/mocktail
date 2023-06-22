# typed: strict

module Mocktail
  class CollectsCalls
    extend T::Sig

    sig { params(double: Object, method_name: T.nilable(Symbol)).returns(T::Array[Call]) }
    def collect(double, method_name)
      calls = ExplainsThing.new.explain(double).reference.calls

      if method_name.nil?
        calls
      else
        calls.select { |call| call.method.to_s == method_name.to_s }
      end
    end
  end
end
