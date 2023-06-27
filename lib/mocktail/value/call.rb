module Mocktail
  class Call < T::Struct
    extend T::Sig

    const :singleton
    const :double, default: nil
    const :original_type
    const :dry_type
    const :method, without_accessors: true
    const :original_method
    const :args, default: []
    const :kwargs, default: {}
    # At present, there's no way to type optional/variadic params in blocks
    #   (i.e. `T.proc.params(*T.untyped).returns(T.untyped)` doesn't work)
    #
    # See: https://github.com/sorbet/sorbet/issues/1142#issuecomment-1586195730
    const :block

    attr_reader :method

    # Because T::Struct compares with referential equality, we need
    # to redefine the equality methods to compare the values of the attributes.

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      case other
      when Call
        [
          :singleton, :double, :original_type, :dry_type,
          :method, :original_method, :args, :kwargs, :block
        ].all? { |attr|
          instance_variable_get("@#{attr}") == other.send(attr)
        }
      else
        false
      end
    end

    def hash
      [@singleton, @double, @original_type, @dry_type, @method, @original_method, @args, @kwargs, @block].hash
    end
  end
end
