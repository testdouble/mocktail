module Mocktail
  class DeclaresDryClass
    def initialize
      @cabinet = Mocktail.cabinet
    end

    def declare(klass)
      instance_methods = instance_methods_on(klass)
      Class.new(klass) {
        [:to_s, :inspect].each do |method_name|
          next if instance_methods.include?(method_name)
          define_method method_name, -> {
            if (id_matches = super().match(/:([0-9a-fx]+)>$/))
              "#<Mocktail of #{klass.name}:#{id_matches[1]}>"
            else
              super()
            end
          }
        end

        instance_methods.each do |method|
          define_method method, ->(*args, **kwargs, &blk) {
            HandlesDryCall.instance.handle(DryCall.new(
              double: self,
              original_class: klass,
              method: method,
              args: args,
              kwargs: kwargs,
              blk: blk
            ))
          }
        end
      }
    end

    private

    def instance_methods_on(klass)
      klass.instance_methods.reject { |m|
        common_ancestors.include?(klass.instance_method(m).owner)
      }
    end

    def common_ancestors
      @common_ancestors ||= begin
        _, *ancestors = Class.new.ancestors
        ancestors
      end
    end
  end
end
