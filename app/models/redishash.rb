class Redishash < Record
  attr_accessible :redis_value

  def redis_value
    value = Redis.current.hvals(self.redis_key)
    value.empty? ? nil : value
  end
end
