# Had to do this because otherwise we get this in our test_helper:
# Unable to resolve constant RuntimeLevels https://srb.help/5002
#    if T::Private::RuntimeLevels.default_checked_level == :never
module T
  module Private
    module RuntimeLevels
      class << self
        if !instance_method(:default_checked_level)
          def default_checked_level
            raise "This should be unreachable"
          end
        end
      end
    end
  end
end
