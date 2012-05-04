module RedisInfosHelper
  def redis_configurations
    @config = []
    
    @config << Redis.current.info["keyspace_hits"].to_i
    @config << Redis.current.info["keyspace_misses"].to_i
    @config << Redis.current.info["total_connections_received"].to_i
    @config << Redis.current.info["total_commands_processed"].to_i
    @config << Redis.current.info["expired_keys"].to_i
    @config << Redis.current.info["evicted_keys"].to_i

    @config
  end
end
