# typed: false
module Mocktail
  DemoConfig = Struct.new(
    :ignore_block,
    :ignore_extra_args,
    :ignore_arity,
    :times,
    keyword_init: true
  )
end
