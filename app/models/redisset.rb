class Redisset < Record
  paginates_per 10
  attr_accessible :redis_value

  def redis_value
    Redis.current.smembers(self.redis_key)
  end
end
