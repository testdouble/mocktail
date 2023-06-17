# typed: true

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
