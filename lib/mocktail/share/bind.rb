# typed: true

module Mocktail
  module Bind
    def self.call(mock, method_name, *args, **kwargs, &blk)
      if Mocktail.cabinet.double_for_instance(mock)
        T.unsafe(Object.instance_method(method_name)).bind_call(mock, *args, **kwargs, &blk)
      elsif (type_replacement = TopShelf.instance.type_replacement_if_exists_for(mock)) &&
          (og_method = type_replacement.original_methods&.find { |m| m.name == method_name })
        og_method.call(*args, **kwargs, &blk)
      else
        mock.__send__(method_name, *args, **kwargs, &blk)
      end
    end
  end
end
