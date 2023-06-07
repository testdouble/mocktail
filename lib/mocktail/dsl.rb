# typed: false

module Mocktail
  module DSL
    extend T::Sig

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
    def stubs(ignore_block: false, ignore_extra_args: false, ignore_arity: false, times: nil, &demo)
      RegistersStubbing.new.register(demo, DemoConfig.new(
        ignore_block: ignore_block,
        ignore_extra_args: ignore_extra_args,
        ignore_arity: ignore_arity,
        times: times
      ))
    end

    def verify(ignore_block: false, ignore_extra_args: false, ignore_arity: false, times: nil, &demo)
      VerifiesCall.new.verify(demo, DemoConfig.new(
        ignore_block: ignore_block,
        ignore_extra_args: ignore_extra_args,
        ignore_arity: ignore_arity,
        times: times
      ))
    end
  end
end
