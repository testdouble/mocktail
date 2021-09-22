# The top shelf stores all cross-thread & thread-aware state, so anything that
# goes here is on its own when it comes to ensuring thread safety.
module Mocktail
  class TopShelf
    def self.instance
      @self ||= new
    end

    def initialize
      @type_replacements = {}
      @new_registrations = {}
      @of_next_registrations = {}
      @singleton_method_registrations = {}
    end

    def type_replacement_for(type)
      @type_replacements[type] ||= TypeReplacement.new(type: type)
    end

    def reset_current_thread!
      @new_registrations[Thread.current] = []
      @of_next_registrations[Thread.current] = []
      @singleton_method_registrations[Thread.current] = []
    end

    def register_new_replacement!(type)
      @new_registrations[Thread.current] ||= []
      @new_registrations[Thread.current] |= [type]
    end

    def new_replaced?(type)
      @new_registrations[Thread.current] ||= []
      @new_registrations[Thread.current].include?(type)
    end

    def register_of_next_replacement!(type)
      @of_next_registrations[Thread.current] ||= []
      @of_next_registrations[Thread.current] |= [type]
    end

    def of_next_registered?(type)
      @of_next_registrations[Thread.current] ||= []
      @of_next_registrations[Thread.current].include?(type)
    end

    def unregister_of_next_replacement!(type)
      @of_next_registrations[Thread.current] ||= []
      @of_next_registrations[Thread.current] -= [type]
    end

    def register_singleton_method_replacement!(type)
      @singleton_method_registrations[Thread.current] ||= []
      @singleton_method_registrations[Thread.current] |= [type]
    end

    def singleton_methods_replaced?(type)
      @singleton_method_registrations[Thread.current] ||= []
      @singleton_method_registrations[Thread.current].include?(type)
    end
  end
end
