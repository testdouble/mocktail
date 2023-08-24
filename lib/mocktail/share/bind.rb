module Mocktail
  module Bind
    # sig intentionally omitted, because the wrapper will cause infinite recursion if certain methods are mocked
    def self.call(mock, method_name, *args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      if Mocktail.cabinet.double_for_instance(mock)
        Object.instance_method(method_name).bind_call(mock, *args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      elsif (mock.is_a?(Module) || mock.is_a?(Class)) &&
          (type_replacement = TopShelf.instance.type_replacement_if_exists_for(mock)) &&
          (og_method = type_replacement.original_methods&.find { |m| m.name == method_name })
        og_method.call(*args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      else
        mock.__send__(method_name, *args, **kwargs, &blk) # standard:disable Style/ArgumentsForwarding
      end
    end
  end
end
