require "test_helper"

module Mocktail
  class RaisesNeatoNoMethodErrorTest < Minitest::Test
    def setup
      @subject = RaisesNeatoNoMethodError.new
    end

    class Garage
      def close
      end
    end

    def test_basic_call
      e = assert_raises(NoMethodError) {
        @subject.call(Call.new(
          original_type: Garage,
          method: :open,
          args: [],
          kwargs: {},
          block: nil
        ))
      }

      assert_equal <<~MSG, e.message
        No method `Mocktail::RaisesNeatoNoMethodErrorTest::Garage#open' exists for call:

          open()

        Need to define the method? Here's a sample definition:

          def open
          end

      MSG
    end

    def test_convoluted_call
      e = assert_raises(NoMethodError) {
        @subject.call(Call.new(
          original_type: Garage,
          method: :open,
          args: [42, :pants, "99bottles", "and some space", "11 t@hi|ngs 29|@#", :pants, "*"],
          kwargs: {a: 1, b: 2},
          block: proc {}
        ))
      }

      assert_equal <<~MSG, e.message
        No method `Mocktail::RaisesNeatoNoMethodErrorTest::Garage#open' exists for call:

          open(42, :pants, "99bottles", "and some space", "11 t@hi|ngs 29|@#", :pants, "*", a: 1, b: 2) {…}

        Need to define the method? Here's a sample definition:

          def open(arg, pants, bottles, and_some_space, things_29, pants2, arg2, a:, b:, &blk)
          end

      MSG
    end

    def test_did_you_mean_dictionary
      e = assert_raises(NoMethodError) {
        @subject.call(Call.new(
          original_type: Garage,
          method: :closes,
          args: ["stuff"],
          kwargs: {},
          block: nil
        ))
      }

      assert_equal <<~MSG, e.message
        No method `Mocktail::RaisesNeatoNoMethodErrorTest::Garage#closes' exists for call:

          closes("stuff")

        Need to define the method? Here's a sample definition:

          def closes(stuff)
          end

        There are also 3 similar methods on Mocktail::RaisesNeatoNoMethodErrorTest::Garage.

        Did you mean?
          close
          clone
          class

      MSG
    end
  end
end
