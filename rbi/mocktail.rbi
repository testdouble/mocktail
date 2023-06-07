# typed: true

module Mocktail
  extend ::Mocktail::DSL

  class << self
    sig {
      type_parameters(:T)
        .params(type: T::Class[T.type_parameter(:T)])
        .returns(T.type_parameter(:T))
    }
    def of(type)
    end

    sig {
      type_parameters(:T)
        .params(type: T::Class[T.type_parameter(:T)], count: T.nilable(Integer))
        .returns(T.type_parameter(:T))
    }
    def of_next(type, count: T.unsafe(nil))
    end

    sig {
      type_parameters(:T)
        .params(type: T::Class[T.type_parameter(:T)], count: T.nilable(Integer))
        .returns(T::Array[T.type_parameter(:T)])
    }
    def of_next_with_count(type, count:)
    end
  end
end

module Mocktail::DSL
  sig {
    type_parameters(:T)
      .params(
        ignore_block: T.nilable(T::Boolean),
        ignore_extra_args: T.nilable(T::Boolean),
        ignore_arity: T.nilable(T::Boolean),
        times: T.nilable(Integer),
        demo: T.proc.params(matchers: Mocktail::MatcherPresentation).returns(T.type_parameter(:T))
      )
      .returns(Mocktail::Stubbing[T.type_parameter(:T)])
  }
  def stubs(ignore_block: T.unsafe(nil), ignore_extra_args: T.unsafe(nil), ignore_arity: T.unsafe(nil), times: T.unsafe(nil), &demo)
  end

  sig {
    type_parameters(:T)
      .params(
        ignore_block: T.nilable(T::Boolean),
        ignore_extra_args: T.nilable(T::Boolean),
        ignore_arity: T.nilable(T::Boolean),
        times: T.nilable(Integer),
        demo: T.proc.params(matchers: Mocktail::MatcherPresentation).void
      ).void
  }
  def verify(ignore_block: T.unsafe(nil), ignore_extra_args: T.unsafe(nil), ignore_arity: T.unsafe(nil), times: T.unsafe(nil), &demo)
  end
end

class Mocktail::Stubbing < ::Struct
  extend T::Generic
  MethodReturnType = type_member

  sig { params(block: T.proc.returns(MethodReturnType)).void }
  def with(&block)
  end
end

class Mocktail::MatcherPresentation
  sig {
    returns(T.untyped)
  }
  def any
  end

  sig {
    type_parameters(:T)
      .params(expected: T::Class[T.type_parameter(:T)])
      .returns(T.type_parameter(:T))
  }
  def is_a(expected)
  end

  sig {
    type_parameters(:T)
      .params(expecteds: T.type_parameter(:T))
      .returns(T::Array[T.type_parameter(:T)])
  }
  def includes(*expecteds)
  end

  sig {
    type_parameters(:T)
      .params(expecteds: T.type_parameter(:T))
      .returns(T.type_parameter(:T))
  }
  def includes_string(*expecteds)
  end

  sig {
    type_parameters(:K, :V)
      .params(expecteds: T::Hash[T.type_parameter(:K), T.type_parameter(:V)])
      .returns(T::Hash[T.type_parameter(:K), T.type_parameter(:V)])
  }
  def includes_hash(*expecteds)
  end

  sig {
    type_parameters(:K, :V)
      .params(expecteds: T.type_parameter(:K))
      .returns(T::Hash[T.type_parameter(:K), T.type_parameter(:V)])
  }
  def includes_key(*expecteds)
  end

  sig {
    params(pattern: T.any(String, Regexp)).returns(String)
  }
  def matches(pattern)
  end

  sig {
    returns(T.untyped)
  }
  def numeric
  end

  sig {
    params(
      blk: T.proc.params(arg: T.untyped).returns(T::Boolean)
    ).returns(T.untyped)
  }
  def that(&blk)
  end

  sig {
    type_parameters(:T)
      .params(unexpected: T.type_parameter(:T))
      .returns(T.type_parameter(:T))
  }
  def not(unexpected)
  end
end
