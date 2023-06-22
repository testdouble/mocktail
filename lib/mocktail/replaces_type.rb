# typed: strict

require_relative "replaces_type/redefines_new"
require_relative "replaces_type/redefines_singleton_methods"
require_relative "replaces_type/runs_sorbet_sig_blocks_before_replacement"

module Mocktail
  class ReplacesType
    extend T::Sig

    sig { void }
    def initialize
      @top_shelf = T.let(TopShelf.instance, TopShelf)
      @runs_sorbet_sig_blocks_before_replacement = T.let(RunsSorbetSigBlocksBeforeReplacement.new, RunsSorbetSigBlocksBeforeReplacement)
      @redefines_new = T.let(RedefinesNew.new, RedefinesNew)
      @redefines_singleton_methods = T.let(RedefinesSingletonMethods.new, RedefinesSingletonMethods)
    end

    sig { params(type: T.any(T::Class[T.anything], Module)).void }
    def replace(type)
      unless T.unsafe(type).is_a?(Class) || T.unsafe(type).is_a?(Module)
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
