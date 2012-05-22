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

  def redis_size(db, k)
    t = db.type(k)
    case t
      when 'string' then db.get(k).length
      when 'list'   then db.lrange(k, 0, -1).size
      when 'zset'   then db.zrange(k, 0, -1).size
      when 'set'    then db.smembers(k).size
      when 'hash'   then db.hvals(k).size
      else raise("Redis type '#{t}' not yet supported.")
    end
  end

  def array_sum(array)
    array.inject(0){ |sum, e| sum + e }
  end

  def redis_db_profile
    db = Redis.current
    keys = Redis.current.keys

    key_patterns = keys.group_by{ |key| key.gsub(/\d+/, '#') }
    data = key_patterns.map{ |pattern, keys|
      [pattern, {'keys' => keys.size, 'size' => array_sum(keys.map{ |k| redis_size(db, k) })}]
    }.sort_by{ |a| a.last['size'] }.reverse
    size_sum = data.inject(0){|sum, d| sum += d.last['size'] }
    data.each { |d| d.last['percent'] = '%.2f%' % (d.last['size'].to_f*100/size_sum) }
  end

=begin
[["o", {"keys"=>1, "size"=>7, "percent"=>"12.28%"}],
 ["hoamian", {"keys"=>1, "size"=>6, "percent"=>"10.53%"}],
 ["hao", {"keys"=>1, "size"=>6, "percent"=>"10.53%"}],
 ["fisrt", {"keys"=>1, "size"=>4, "percent"=>"7.02%"}],
 ["listkey", {"keys"=>1, "size"=>4, "percent"=>"7.02%"}],
 ["setkey", {"keys"=>1, "size"=>4, "percent"=>"7.02%"}],
 ["ThirdList", {"keys"=>1, "size"=>3, "percent"=>"5.26%"}],
 ["for redis ", {"keys"=>1, "size"=>3, "percent"=>"5.26%"}],
 ["asdffasdfasdf", {"keys"=>1, "size"=>3, "percent"=>"5.26%"}],
 ["Contributing for SmartRedis", {"keys"=>1, "size"=>3, "percent"=>"5.26%"}],
 ["asd#z", {"keys"=>1, "size"=>3, "percent"=>"5.26%"}],
 ["Why SmartRedis comes here", {"keys"=>1, "size"=>2, "percent"=>"3.51%"}],
 ["zsetkey", {"keys"=>1, "size"=>2, "percent"=>"3.51%"}],
 ["hashkey", {"keys"=>1, "size"=>2, "percent"=>"3.51%"}],
 ["FirstList", {"keys"=>1, "size"=>1, "percent"=>"1.75%"}],
 ["asdf", {"keys"=>1, "size"=>1, "percent"=>"1.75%"}],
 ["支持中文输入的list", {"keys"=>1, "size"=>1, "percent"=>"1.75%"}],
 ["SecondList", {"keys"=>1, "size"=>1, "percent"=>"1.75%"}],
 ["c.cao", {"keys"=>1, "size"=>1, "percent"=>"1.75%"}]]
=end

end
