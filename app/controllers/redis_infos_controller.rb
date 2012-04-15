class RedisInfosController < ApplicationController
  def index
    @info = Redis.current.info
  end
end
