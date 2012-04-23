class Product < ActiveRecord::Base
  attr_accessible :name, :redis_key, :redis_value
  
  def redis_key
    #"list:#{self.id}:#{self.name}"
    self.name.to_s
  end

  def redis_value
    Redis.current.lrange(self.redis_key, 0, -1).join(",")
  end

  def type
    Redis.current.type self.redis_key
  end

  def ttl
    Redis.current.ttl self.redis_key
  end
  

  # => Example
  # Redis.current.set("list:1:key", "value")
  #
end
