require_relative "typed"

# Constant boolean, so won't statically type-check, but `T.unsafe` can't be used
# because we haven't required sorbet-runtime yet
if eval("Mocktail::TYPED", binding, __FILE__, __LINE__)
  require "sorbet-runtime"
else
  require "#{Gem.loaded_specs["sorbet-eraser"].gem_dir}/lib/t"
end
