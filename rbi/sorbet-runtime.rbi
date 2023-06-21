# typed: true

# sorbet gem fails to export some of these constants, so we need to in order to
# pass static typecheck
module T
  module Private
    module RuntimeLevels
      class << self
        sig { returns(Symbol) }
        def default_checked_level
        end
      end
    end

    module Methods
      class Signature
        sig { returns(T::Array[T::Array[Symbol]]) }
        def parameters
        end
      end
    end
  end
end
