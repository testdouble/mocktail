# typed: true
module Mocktail
  class TopShelf
    def self.instance
      Thread.current[:mocktail_top_shelf] ||= new
    end

    @@type_replacements = {}
    @@type_replacements_mutex = Mutex.new

    def initialize
      @new_registrations = []
      @of_next_registrations = []
      @singleton_method_registrations = []
    end

    def type_replacement_for(type)
      @@type_replacements_mutex.synchronize {
        @@type_replacements[type] ||= TypeReplacement.new(type: type)
      }
    end

    def type_replacement_if_exists_for(type)
      @@type_replacements_mutex.synchronize {
        @@type_replacements[type]
      }
    end

    def reset_current_thread!
      Thread.current[:mocktail_top_shelf] = self.class.new
    end

    def register_new_replacement!(type)
      @new_registrations |= [type]
    end

    def new_replaced?(type)
      @new_registrations.include?(type)
    end

    def register_of_next_replacement!(type)
      @of_next_registrations |= [type]
    end

    def of_next_registered?(type)
      @of_next_registrations.include?(type)
    end

    def unregister_of_next_replacement!(type)
      @of_next_registrations -= [type]
    end

    def register_singleton_method_replacement!(type)
      @singleton_method_registrations |= [type]
    end

    def singleton_methods_replaced?(type)
      @singleton_method_registrations.include?(type)
    end
  end
end
