# typed: true

module Mocktail
  class DemoConfig < T::Struct
    const :ignore_block, T.nilable(T::Boolean)
    const :ignore_extra_args, T.nilable(T::Boolean)
    const :ignore_arity, T.nilable(T::Boolean)
    const :times, T.nilable(Integer)
  end
end
