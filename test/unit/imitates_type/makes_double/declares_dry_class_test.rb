# typed: strict

module Mocktail
  class DeclaresDryClassTest < TLDR
    include Mocktail::DSL
    extend T::Sig

    sig { void }
    def initialize
      @subject = T.let(DeclaresDryClass.new, DeclaresDryClass)
    end

    class Fib
      extend T::Sig

      sig { params(truth: T.untyped, lies: T.untyped).returns(T.untyped) }
      def lie(truth, lies:)
        :bald_faced
      end
    end

    module Curse
      extend T::Sig

      sig { params(words: T.untyped).returns(T.untyped) }
      def swear(words)
        :dirty_rotten
      end
    end

    sig { void }
    def test_declares_dry_class_from_class
      fake_fib_class = @subject.declare(Fib, [:lie])
      fake_fib = fake_fib_class.new

      assert_nil fake_fib.lie("truth", lies: "lies")
      e = assert_raises(NoMethodError) { T.unsafe(fake_fib).be_honest }
      assert_equal <<~MSG, e.message
        No method `Mocktail::DeclaresDryClassTest::Fib#be_honest' exists for call:

          be_honest()

        Need to define the method? Here's a sample definition:

          def be_honest
          end

      MSG
      assert fake_fib.is_a?(Fib)
      assert fake_fib.kind_of?(Fib) # standard:disable Style/ClassCheck
      assert_match(/#<Mocktail of Mocktail::DeclaresDryClassTest::Fib:0x/, fake_fib.to_s)
      assert_match(/#<Mocktail of Mocktail::DeclaresDryClassTest::Fib:0x/, fake_fib.inspect)
    end

    sig { void }
    def test_declares_dry_class_from_module
      skip unless runtime_type_checking_disabled?

      fake_curse_class = T.cast(T.unsafe(@subject).declare(Curse, [:swear]), T::Class[T.all(Curse, Object)])
      fake_curse = fake_curse_class.new

      assert_nil fake_curse.swear(%w[bad words])
      e = assert_raises(NoMethodError) { T.unsafe(fake_curse).clean_it_up! }
      assert_equal <<~MSG, e.message
        No method `Mocktail::DeclaresDryClassTest::Curse#clean_it_up!' exists for call:

          clean_it_up!()

        Need to define the method? Here's a sample definition:

          def clean_it_up!
          end

      MSG
      assert fake_curse.is_a?(Curse)
      assert fake_curse.kind_of?(Curse) # standard:disable Style/ClassCheck
      assert_match(/#<Mocktail of Mocktail::DeclaresDryClassTest::Curse:0x/, fake_curse.to_s)
      assert_match(/#<Mocktail of Mocktail::DeclaresDryClassTest::Curse:0x/, fake_curse.inspect)
    end

    sig { void }
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
      extend T::Sig

      sig { params(binding: T.untyped, type: T.untyped, dry_class: T.untyped, method: T.untyped, signature: T.untyped).returns(T.untyped) }
      def welp(binding, type, dry_class, method, signature)
      end
    end

    sig { void }
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
