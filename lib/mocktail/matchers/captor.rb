# typed: strict

module Mocktail::Matchers
  # Captors are conceptually complex implementations, but with a simple usage/purpose:
  # They are values the user can create and hold onto that will return a matcher
  # and then "capture" the value made by the real call, for later analysis & assertion.
  #
  # Unlike other matchers, these don't make any useful sense for stubbing, but are
  # very useful when asserting complication call verifications
  #
  # The fact the user will need the reference outside the verification call is
  # why this is a top-level method on Mocktail, and not included in the |m| block
  # arg to stubs/verify
  #
  # See Mockito, which is the earliest implementation I know of:
  # https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Captor.html
  class Captor
    extend T::Sig

    class Capture < Mocktail::Matchers::Base
      extend T::Sig

      sig { returns(Symbol) }
      def self.matcher_name
        :capture
      end

      sig { returns(T.untyped) }
      attr_reader :value

      sig { void }
      def initialize
        @value = T.let(nil, T.untyped)
        @captured = T.let(false, T::Boolean)
      end

      sig { params(actual: T.untyped).returns(TrueClass) }
      def match?(actual)
        @value = actual
        @captured = true
        true
      end

      sig { returns(T::Boolean) }
      def captured?
        @captured
      end

      sig { returns(String) }
      def inspect
        "capture"
      end
    end

    # This T.untyped is intentional. Even though a Capture is surely returned,
    # in order for a verification demonstration to pass its own type check,
    # it needs to think it's being returned whatever parameter is expected
    sig { returns(T.untyped) }
    attr_reader :capture

    sig { void }
    def initialize
      @capture = T.let(Capture.new, Capture)
    end

    sig { returns(T::Boolean) }
    def captured?
      @capture.captured?
    end

    sig { returns(T.untyped) }
    def value
      @capture.value
    end
  end
end
