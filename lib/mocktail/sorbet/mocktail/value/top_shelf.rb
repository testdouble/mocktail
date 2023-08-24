# typed: strict

module Mocktail
  # The TopShelf is where we keep all the more global, dangerous state.
  # In particular, this is where Mocktail manages state related to singleton
  # method replacements carried out with Mocktail.replace(ClassOrModule)
  class TopShelf
    extend T::Sig

    sig { returns(TopShelf) }
    def self.instance
      Thread.current[:mocktail_top_shelf] ||= new
    end

    @@type_replacements = T.let({}, T::Hash[T.any(Module, T::Class[T.anything]), TypeReplacement])
    @@type_replacements_mutex = T.let(Mutex.new, Mutex)

    sig { void }
    def initialize
      @new_registrations = T.let([], T::Array[T.any(Module, T::Class[T.anything])])
      @of_next_registrations = T.let([], T::Array[T::Class[T.anything]])
      @singleton_method_registrations = T.let([], T::Array[T.any(Module, T::Class[T.anything])])
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).returns(TypeReplacement) }
    def type_replacement_for(type)
      @@type_replacements_mutex.synchronize {
        @@type_replacements[type] ||= TypeReplacement.new(type: type)
      }
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).returns(T.nilable(TypeReplacement)) }
    def type_replacement_if_exists_for(type)
      @@type_replacements_mutex.synchronize {
        @@type_replacements[type]
      }
    end

    sig { void }
    def reset_current_thread!
      Thread.current[:mocktail_top_shelf] = self.class.new
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).void }
    def register_new_replacement!(type)
      @new_registrations |= [type]
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).returns(T::Boolean) }
    def new_replaced?(type)
      @new_registrations.include?(type)
    end

    sig { params(type: T::Class[T.anything]).void }
    def register_of_next_replacement!(type)
      @of_next_registrations |= [type]
    end

    sig { params(type: T::Class[T.anything]).returns(T::Boolean) }
    def of_next_registered?(type)
      @of_next_registrations.include?(type)
    end

    sig { params(type: T::Class[T.anything]).void }
    def unregister_of_next_replacement!(type)
      @of_next_registrations -= [type]
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).void }
    def register_singleton_method_replacement!(type)
      @singleton_method_registrations |= [type]
    end

    sig { params(type: T.any(Module, T::Class[T.anything])).returns(T::Boolean) }
    def singleton_methods_replaced?(type)
      @singleton_method_registrations.include?(type)
    end
  end
end
