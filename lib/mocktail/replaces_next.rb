module Mocktail
  class ReplacesNext
    def initialize
      @imitates_type = ImitatesType.new.imitate(type)
    end

    def replace(type, count)
      mocktails = count.times { @imitates_type.imitate(type) }

      # mock_new_if_not_mocked

      mocktails.reverse.each.with_index do |mocktail, i|
        stubs(
          ignore_extra_args: true,
          ignore_block: true,
          ignore_arity: true,
          times: 1
        ) {
          type.new
        }.with {
          if i + 1 == mocktails.size
            # unmock_new_if_class isn't replaced on thread
          end

          mocktail
        }
      end

      mocktails.size == 1 ? mocktails.first : mocktails
    end
  end
end
