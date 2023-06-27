require_relative "replaces_type/redefines_new"
require_relative "replaces_type/redefines_singleton_methods"
require_relative "replaces_type/runs_sorbet_sig_blocks_before_replacement"

module Mocktail
  class ReplacesType
    extend T::Sig

    def initialize
      @top_shelf = TopShelf.instance
      @runs_sorbet_sig_blocks_before_replacement = RunsSorbetSigBlocksBeforeReplacement.new
      @redefines_new = RedefinesNew.new
      @redefines_singleton_methods = RedefinesSingletonMethods.new
    end

    def replace(type)
      unless type.is_a?(Class) || type.is_a?(Module)
        raise UnsupportedMocktail.new("Mocktail.replace() only supports classes and modules")
      end

      @runs_sorbet_sig_blocks_before_replacement.run(type)

      if type.is_a?(Class)
        @top_shelf.register_new_replacement!(type)
        @redefines_new.redefine(type)
      end

      @top_shelf.register_singleton_method_replacement!(type)
      @redefines_singleton_methods.redefine(type)
    end
  end
end
