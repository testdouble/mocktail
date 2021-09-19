module Mocktail
  class DeclaresDryClass
    def declare(type)
      type_type = type_of(type)
      instance_methods = instance_methods_on(type)
      Class.new(type_type == :class ? type : Object) {
        include type if type_type == :module

        [:to_s, :inspect].each do |method_name|
          define_singleton_method method_name, -> {
            if (id_matches = super().match(/:([0-9a-fx]+)>$/))
              "#<Class #{"including module " if type_type == :module}for mocktail of #{type.name}:#{id_matches[1]}>"
            else
              super()
            end
          }

          next if instance_methods.include?(method_name)
          define_method method_name, -> {
            if (id_matches = super().match(/:([0-9a-fx]+)>$/))
              "#<Mocktail of #{type.name}:#{id_matches[1]}>"
            else
              super()
            end
          }
        end

        instance_methods.each do |method|
          define_method method, ->(*args, **kwargs, &block) {
            HandlesDryCall.instance.handle(Call.new(
              double: self,
              original_type: type,
              dry_type: self.class,
              method: method,
              args: args,
              kwargs: kwargs,
              block: block
            ))
          }
        end
      }
    end

    private

    def type_of(type)
      if type.is_a?(Class)
        :class
      elsif type.is_a?(Module)
        :module
      end
    end

    def instance_methods_on(type)
      type.instance_methods.reject { |m|
        ignored_ancestors.include?(type.instance_method(m).owner)
      }
    end

    def ignored_ancestors
      Object.ancestors
    end
  end
end
