module Mocktail
  module RefinedSorbetWrappedMethods
    if defined?(T::CompatibilityPatches::MethodExtensions)
      refine Method do
        T::CompatibilityPatches::MethodExtensions.instance_methods(false).each do |method|
          define_method(
            method,
            T::CompatibilityPatches::MethodExtensions.instance_method(method)
          )
        end
      end
    end
  end
end
