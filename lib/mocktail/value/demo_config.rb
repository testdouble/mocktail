# typed: strict

module Mocktail
  class DemoConfig < T::Struct
    const :ignore_block, T.nilable(T::Boolean), default: false
    const :ignore_extra_args, T.nilable(T::Boolean), default: false
    const :ignore_arity, T.nilable(T::Boolean), default: false
    const :times, T.nilable(Integer), default: nil
  end
end
