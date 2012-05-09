class Product < Record
  paginates_per 10
  attr_accessible :redis_value

  def redis_value
    Redis.current.lrange(self.redis_key, 0, -1).join(",")
  end
end
