module Mocktail
  class TopShelf
    def self.instance
      @self ||= new
    end

    def initialize
      @type_replacements = {}
      @registrations = {}
    end

    def type_replacement_for(type)
      @type_replacements[type] ||= TypeReplacement.new(type: type)
    end

    def replaced_on_current_thread?(type)
      @registrations[Thread.current] ||= []
      @registrations[Thread.current].include?(type)
    end

    def register_type_replacement_for_current_thread!(type)
      @registrations[Thread.current] ||= []
      @registrations[Thread.current] |= [type]
    end

    def reset_type_replacement_for_current_thread!
      @registrations[Thread.current] = []
    end

    #     def of_next_on_current_thread?(type)
    #       @of_next_registrations[Thread.current] ||= []
    #       @of_next_registrations[Thread.current].include?(type)
    #     end

    #     def register_of_next_for_current_thread!(type)
    #       @of_next_registrations[Thread.current] ||= []
    #       @of_next_registrations[Thread.current] |= [type]
    #     end

    #     def deregister_of_next_for_current_thread!
    #       @of_next_registrations[Thread.current] = []
    #     end
  end
end
