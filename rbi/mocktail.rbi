# typed: true

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
end
