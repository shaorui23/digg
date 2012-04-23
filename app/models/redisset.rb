class Redisset < Record
  attr_accessible :name, :redis_key, :redis_value

  def redis_key
    #"set:#{self.id}:#{self.name}"
    #"sset:#{self.id}:#{self.name}"
    self.name.to_s
  end

  def type
    Redis.current.type self.redis_key
  end

  def ttl
    Redis.current.ttl self.redis_key
  end

  def redis_value
    Redis.current.smembers(self.redis_key)
  end
end
