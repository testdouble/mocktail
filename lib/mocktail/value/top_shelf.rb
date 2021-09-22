module Mocktail
  class TopShelf
    def self.instance
      @self ||= new
    end

    def initialize
      @type_replacements = {}
      @new_registrations = {}
      @singleton_method_registrations = {}
    end

    def type_replacement_for(type)
      @type_replacements[type] ||= TypeReplacement.new(type: type)
    end

    def register_new_replacement!(type)
      @new_registrations[Thread.current] ||= []
      @new_registrations[Thread.current] |= [type]
    end

    def new_replaced?(type)
      @new_registrations[Thread.current] ||= []
      @new_registrations[Thread.current].include?(type)
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
