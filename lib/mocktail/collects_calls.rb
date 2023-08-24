module Mocktail
  class CollectsCalls
    extend T::Sig

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
