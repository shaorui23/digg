class Objected < ActiveRecord::Base
  include Redis::Objects
  
  list :list_for_redis, :global => true

  before_create :set_default_value
  attr_accessible :prefix_list_for_redis

  def prefix_list_for_redis
    list_for_redis
  end

  def prefix_list_for_redis=(value)
    list_for_redis.push value
  end

  private

  def set_default_value
    self.list_for_redis ||= ""
  end
end
