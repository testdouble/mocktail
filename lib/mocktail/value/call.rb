# typed: strict

module Mocktail
  class Call < T::Struct
    extend T::Sig

    const :singleton, T.nilable(T::Boolean)
    const :double, T.nilable(Object)
    const :original_type, T.nilable(T.any(T::Class[T.anything], Module))
    const :dry_type, T.nilable(T.any(T::Class[T.anything], Module))
    const :method, T.nilable(Symbol), without_accessors: true
    const :original_method, T.nilable(T.any(UnboundMethod, Method))
    const :args, T::Array[T.untyped], default: []
    const :kwargs, T::Hash[Symbol, T.untyped], default: {}
    # At present, there's no way to type optional/variadic params in blocks
    #   (i.e. `T.proc.params(*T.untyped).returns(T.untyped)` doesn't work)
    #
    # See: https://github.com/sorbet/sorbet/issues/1142#issuecomment-1586195730
    const :block, T.nilable(Proc)

    sig { returns(T.nilable(Symbol)) }
    attr_reader :method

    # Because T::Struct compares with referential equality, we need
    # to redefine the equality methods to compare the values of the attributes.
    sig { params(other: T.nilable(T.anything)).returns(T::Boolean) }
    def ==(other)
      eql?(other)
    end

    sig { params(other: T.untyped).returns(T::Boolean) }
    def eql?(other)
      self.class == other.class && [
        :singleton, :double, :original_type, :dry_type,
        :method, :original_method, :args, :kwargs, :block
      ].all? { |attr|
        instance_variable_get("@#{attr}") == other.send(attr)
      }
    end

    sig { returns(Integer) }
    def hash
      [@singleton, @double, @original_type, @dry_type, @method, @original_method, @args, @kwargs, @block].hash
    end
  end
end
