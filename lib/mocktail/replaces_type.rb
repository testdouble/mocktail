require_relative "replaces_type/redefines_new"
require_relative "replaces_type/redefines_singleton_methods"

module Mocktail
  class ReplacesType
    def initialize
      @top_shelf = TopShelf.instance
      @redefines_new = RedefinesNew.new
      @redefines_singleton_methods = RedefinesSingletonMethods.new
    end

    def replace(type)
      raise UnsupportedMocktail.new("Mocktail.replace() only supports classes and modules") unless type.is_a?(Class) || type.is_a?(Module)

      if type.is_a?(Class)
        @top_shelf.register_new_replacement!(type)
        @redefines_new.redefine(type)
      end

      @top_shelf.register_singleton_method_replacement!(type)
      @redefines_singleton_methods.redefine(type)
    end
  end
end
