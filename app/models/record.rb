class Record < ActiveRecord::Base
  attr_accessible :name, :redis_key#, :redis_value
  
 #def redis_value
 #  case type
 #  when "Stringlist"
 #    Redis.current.get(self.redis_key)
 #  when "Redisset"
 #    Redis.current.smembers(self.redis_key)
 #  when "Objected"
 #    Redis.current.zrange(self.redis_key, 0, -1).join(",")
 #  when "Product"
 #    Redis.current.lrange(self.redis_key, 0, -1).join(",")
 #  end
 #end

  def redis_key
    self.name.to_s
  end

  def redis_type
    Redis.current.type self.redis_key
  end

  def ttl
    Redis.current.ttl self.redis_key
  end
end
