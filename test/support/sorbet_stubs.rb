# typed: false

module T
  def self.must(*args, **kwargs, &blk)
    args&.first
  end

  def self.unsafe(*args, **kwargs, &blk)
    args&.first
  end

  def self.let(*args, **kwargs, &blk)
    args&.first
  end

  def self.cast(*args, **kwargs, &blk)
    args&.first
  end

  def self.all(*args, **kwargs, &blk)
  end

  def self.untyped
  end

  def self.assert_type!(*args, **kwargs, &blk)
  end

  module Array
    def self.[](*args, **kwargs, &blk)
    end
  end

  module Class
    def self.[](*args, **kwargs, &blk)
    end
  end

  module Sig
    def sig(*args, **kwargs, &blk)
    end
  end
end

module SorbetOverride
  def self.disable_inline_type_checks(&blk)
    blk.call
  end

  def self.disable_call_validation_checks(&blk)
    blk.call
  end
end
