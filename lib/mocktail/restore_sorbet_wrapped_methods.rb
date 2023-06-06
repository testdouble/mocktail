if defined?(T::CompatibilityPatches::MethodExtensions)
  ::Method.prepend(T::CompatibilityPatches::MethodExtensions)
end
