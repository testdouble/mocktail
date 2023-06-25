# typed: strict

module Mocktail
  class DemoConfig < T::Struct
    const :ignore_block, T::Boolean, default: false
    const :ignore_extra_args, T::Boolean, default: false
    const :ignore_arity, T::Boolean, default: false
    const :times, T.nilable(Integer), default: nil
  end
end
