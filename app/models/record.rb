class Record < ActiveRecord::Base
  attr_accessible :name, :redis_key

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
