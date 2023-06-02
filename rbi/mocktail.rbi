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
    def of_next(type, count: 1)
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
        demo: T.proc.returns(T.type_parameter(:T))
      )
      .returns(Mocktail::Stubbing[T.type_parameter(:T)])
  }
  def stubs(ignore_block: false, ignore_extra_args: false, ignore_arity: false, times: nil, &demo)
  end

  # def verify(ignore_block: T.unsafe(nil), ignore_extra_args: T.unsafe(nil), ignore_arity: T.unsafe(nil), times: T.unsafe(nil), &demo); end
end

class Mocktail::Stubbing < ::Struct
  extend T::Generic
  MethodReturnType = type_member

  sig { params(block: T.proc.returns(MethodReturnType)).void }
  def with(&block)
  end
end
