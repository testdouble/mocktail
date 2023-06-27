module Mocktail
  class DemoConfig < T::Struct
    const :ignore_block, default: false
    const :ignore_extra_args, default: false
    const :ignore_arity, default: false
    const :times, default: nil
  end
end
