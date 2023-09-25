# typed: strict

module Mocktail
  class CleansBacktraceTest < TLDR
    extend T::Sig

    sig { void }
    def initialize
      @subject = T.let(CleansBacktrace.new, CleansBacktrace)
    end

    sig { void }
    def test_already_clean_backtrace
      error = make_error
      original = error.backtrace.dup

      @subject.clean(error)

      assert_equal original, error.backtrace
    end

    sig { void }
    def test_one_prepended_frame
      internal_frames = [
        "#{Mocktail::BASE_PATH}/mocktail/mocktail.rb:22:in `of'"
      ]
      error = make_error(
        prepend: internal_frames
      )
      original = T.must(error.backtrace).dup

      @subject.clean(error)

      assert_equal original.reject { |frame|
        internal_frames.any? { |internal_frame|
          frame.include?(internal_frame)
        }
      }, error.backtrace
    end

    sig { void }
    def test_only_removes_prepended_frames
      prepended_frames = [
        "#{Mocktail::BASE_PATH}/mocktail/mocktail.rb:22:in `of'",
        "#{Mocktail::BASE_PATH}/mocktail/mocktail/stuff.rb:425:in (run)",
        "#{Mocktail::BASE_PATH}/mocktail/mocktail/things/and/cool.rb"
      ]
      error = make_error(
        prepend: prepended_frames,
        append: [
          "#{Mocktail::BASE_PATH}/mocktail/how/could/this/happen.rb:11:in `sure'"
        ]
      )
      original = T.must(error.backtrace).dup

      @subject.clean(error)

      assert_equal original.reject { |frame|
        prepended_frames.any? { |internal_frame|
          frame.include?(internal_frame)
        }
      }, error.backtrace
    end

    private

    sig { params(prepend: T::Array[String], append: T::Array[String]).returns(Mocktail::Error) }
    def make_error(prepend: [], append: [])
      raise Error.new
    rescue Mocktail::Error => e
      e.tap do |e|
        e.set_backtrace(
          prepend +
          e.backtrace +
          append
        )
      end
    end
  end
end
