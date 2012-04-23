class Stringlist < ActiveRecord::Base
  
  attr_accessible :name, :redis_key, :redis_value

  def redis_key
    #"string:#{self.id}:#{self.name}"
    self.name.to_s
  end

  def redis_value
    Redis.current.get(self.redis_key)
  end

  def redis_value=(str)
    Redis.current.set(self.redis_key, str)
  end

  def type
    Redis.current.type self.redis_key
  end

  def ttl
    Redis.current.ttl self.redis_key
  end

  # => Example
  # Redis.current.set("string:1:key", "value")
  #
end
