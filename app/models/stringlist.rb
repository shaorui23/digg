class Stringlist < Record
  paginates_per 10

  attr_accessible :redis_value

  def redis_value
    Redis.current.get(self.redis_key)
  end

  def redis_value=(str)
    Redis.current.set(self.redis_key, str)
  end
end
