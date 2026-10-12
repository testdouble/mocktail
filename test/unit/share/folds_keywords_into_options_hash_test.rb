# typed: strict

require "test_helper"

module Mocktail
  class FoldsKeywordsIntoOptionsHashTest < Minitest::Test
    extend T::Sig

    class Fixtures
      extend T::Sig

      sig { params(opts: T.untyped).void }
      def options_hash(opts = {})
      end

      sig { params(a: T.untyped, b: T.untyped).void }
      def positional_then_options_hash(a, b = {})
      end

      sig { params(rest: T.untyped).void }
      def splat(*rest)
      end

      sig { params(a: T.untyped).void }
      def keyword(a:)
      end

      sig { params(kw: T.untyped).void }
      def double_splat(**kw)
      end

      # sorbet-runtime can't build a sig for `**nil`, so skip the sig wrapper
      define_method :no_keywords_accepted, ->(a, b = {}, **nil) {}

      sig { params(opts: T.untyped).void }
      def self.class_options_hash(opts = {})
      end
    end

    sig { void }
    def test_folds_into_an_options_hash
      assert_equal [[{a: 1}], {}], fold(:options_hash, [], {a: 1})
    end

    sig { void }
    def test_folds_after_positional_args
      assert_equal [[1, {a: 1}], {}], fold(:positional_then_options_hash, [1], {a: 1})
    end

    sig { void }
    def test_folds_into_a_splat
      assert_equal [[{a: 1}], {}], fold(:splat, [], {a: 1})
    end

    sig { void }
    def test_leaves_keyword_params_alone
      assert_equal [[], {a: 1}], fold(:keyword, [], {a: 1})
    end

    sig { void }
    def test_leaves_double_splats_alone
      assert_equal [[], {a: 1}], fold(:double_splat, [], {a: 1})
    end

    sig { void }
    def test_leaves_methods_that_accept_no_keywords_alone
      assert_equal [[1], {x: 1}], fold(:no_keywords_accepted, [1], {x: 1})
    end

    sig { void }
    def test_leaves_empty_kwargs_alone
      assert_equal [[], {}], fold(:options_hash, [], {})
    end

    sig { void }
    def test_folds_for_singleton_methods
      assert_equal [[{a: 1}], {}], FoldsKeywordsIntoOptionsHash.new.fold(Fixtures.method(:class_options_hash), [], {a: 1})
    end

    sig { void }
    def test_leaves_kwargs_alone_without_an_original_method
      assert_equal [[], {a: 1}], FoldsKeywordsIntoOptionsHash.new.fold(nil, [], {a: 1})
    end

    private

    sig { params(method_name: Symbol, args: T::Array[T.anything], kwargs: T::Hash[Symbol, T.anything]).returns([T::Array[T.anything], T::Hash[Symbol, T.anything]]) }
    def fold(method_name, args, kwargs)
      FoldsKeywordsIntoOptionsHash.new.fold(Fixtures.instance_method(method_name), args, kwargs)
    end
  end
end
