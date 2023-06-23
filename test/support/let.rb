# typed: strict

module Let
  extend T::Sig
  include Kernel

  sig {
    type_parameters(:T)
      .params(method_name: Symbol, initializer: T.proc.returns(T.type_parameter(:T)))
      .returns(T.type_parameter(:T))
  }
  def let(method_name, &initializer)
    current_test_name = case self
    when Minitest::Test
      name
    else
      "not_a_test"
    end

    @__memos ||= T.let({}, T.nilable(T::Hash[Symbol, T::Hash[Symbol, T.untyped]]))
    method_memos = @__memos[current_test_name] ||= {}
    method_memos[method_name] ||= initializer.call
    define_singleton_method method_name do
      method_memos[method_name]
    end
    method_memos[method_name]
  end

  # sig {
  #   type_parameters(:T)
  #     .params(initializer: T.proc.returns(T.type_parameter(:T)))
  #     .returns(T.type_parameter(:T))
  # }
  # def subject(&initializer)
  #   let(:subject, &initializer)
  # end
end
