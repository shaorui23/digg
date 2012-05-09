class Objected < Record
  paginates_per 10
  attr_accessible :redis_value, :score

  def redis_value
    Redis.current.zrange(self.redis_key, 0, -1).join(",")
  end
end
