# typed: strict

module Mocktail
  class GathersFakeableInstanceMethods
    extend T::Sig

    def gather(type)
      methods = type.instance_methods + [
        (:respond_to_missing? if type.private_method_defined?(:respond_to_missing?))
      ].compact

      methods.reject { |m|
        ignore?(type, m)
      }
    end

    def ignore?(type, method_name)
      ignored_ancestors.include?(type.instance_method(method_name).owner)
    end

    def ignored_ancestors
      Object.ancestors
    end
  end
end
