# typed: true

require "test_helper"

module Mocktail
  class DeclaresDryClassTest < Minitest::Test
    include Mocktail::DSL

    def setup
      @subject = DeclaresDryClass.new
    end

    class Fib
      def lie(truth, lies:)
      end
    end

    def test_calls_handle_dry_call_with_what_we_want
      fake_fib_class = @subject.declare(Fib, [:lie])
      fake_fib = fake_fib_class.new
      handles_dry_call = Mocktail.of_next(HandlesDryCall)

      fake_fib.lie("truth", lies: "lies")

      verify {
        handles_dry_call.handle(Call.new(
          singleton: false,
          double: fake_fib,
          original_type: Fib,
          dry_type: fake_fib_class,
          method: :lie,
          original_method: Fib.instance_method(:lie),
          args: ["truth"],
          kwargs: {lies: "lies"},
          block: nil
        ))
      }
    end

    class ExtremelyUnfortunateArgNames
      def welp(binding, type, dry_class, method, signature)
      end
    end

    def test_handles_args_with_unfortunate_names
      fake_class = @subject.declare(ExtremelyUnfortunateArgNames, [:welp])
      fake = fake_class.new
      handles_dry_call = Mocktail.of_next(HandlesDryCall)

      fake.welp(:a_binding, :a_type, :a_dry_class, :a_method, :a_signature)

      verify {
        handles_dry_call.handle(Call.new(
          singleton: false,
          double: fake,
          original_type: ExtremelyUnfortunateArgNames,
          dry_type: fake_class,
          method: :welp,
          original_method: ExtremelyUnfortunateArgNames.instance_method(:welp),
          args: [:a_binding, :a_type, :a_dry_class, :a_method, :a_signature],
          kwargs: {},
          block: nil
        ))
      }
    end
  end
end
