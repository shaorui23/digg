class Redisset < Record
  paginates_per 10
  attr_accessible :redis_value

  def redis_value
    value = Redis.current.smembers(self.redis_key)
    value.empty? ? nil : value
  end
end
