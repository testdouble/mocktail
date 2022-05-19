# typed: true
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
    class Capture < Mocktail::Matchers::Base
      def self.matcher_name
        :capture
      end

      attr_reader :value

      def initialize
        @value = nil
        @captured = false
      end

      def match?(actual)
        @value = actual
        @captured = true
        true
      end

      def captured?
        @captured
      end

      def inspect
        "capture"
      end
    end

    attr_reader :capture
    def initialize
      @capture = Capture.new
    end

    def captured?
      @capture.captured?
    end

    def value
      @capture.value
    end
  end
end
