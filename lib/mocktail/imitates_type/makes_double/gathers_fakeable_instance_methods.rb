# typed: strict

module Mocktail
  class GathersFakeableInstanceMethods
    extend T::Sig

    sig { params(type: T.any(T::Class[T.anything], Module)).returns(T::Array[Symbol]) }
    def gather(type)
      methods = type.instance_methods + [
        (:respond_to_missing? if type.private_method_defined?(:respond_to_missing?))
      ].compact

      methods.reject { |m|
        ignore?(type, m)
      }
    end

    sig { params(type: T.any(T::Class[T.anything], Module), method_name: Symbol).returns(T::Boolean) }
    def ignore?(type, method_name)
      ignored_ancestors.include?(type.instance_method(method_name).owner)
    end

    sig { returns(T::Array[Module]) }
    def ignored_ancestors
      Object.ancestors
    end
  end
end
