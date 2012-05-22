# coding: utf-8
class RedisInfosController < ApplicationController

  def index
    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis 信息", "/redis_infos"
    @info = Redis.current.info
  end

  def graph
    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis 信息", "/redis_infos"
    add_breadcrumb "Redis 图表"
    @info = Redis.current.info
    @data = []

    types = []
    Redis.current.keys.each do |key|
      types.push(Redis.current.type(key).to_s)
    end
    types.uniq!

    types.each do |type|
      temp = []
      num = 0
      temp.push type.to_s
      Redis.current.keys.each do |key|
        num += 1 if type == Redis.current.type(key)
      end
      #temp.push num
      temp.push (num/Redis.current.keys.count.to_f)
      @data.push(temp)
    end
  end
  
  def export
    begin 
      # should return true
      %x[redis-dump -u 127.0.0.1:6379 > ~/Desktop/test.json]
      redirect_to redis_infos_path
    rescue => e
      puts "!!! Can not export file !!!"
    end
  end

  def import
    begin
      system(%[cat ~/Desktop/#{params[:path]} | redis-load])

      Redis.current.keys.each do |key|
        case Redis.current.type(key)
        when "string"
          Stringlist.create(:name => key) unless Stringlist.find_by_name(key)
        when "list"
          Product.create(:name => key) unless Product.find_by_name(key)
        when "set"
          Redisset.create(:name => key) unless Redisset.find_by_name(key)
        when "zset"
          Objected.create(:name => key) unless Objected.find_by_name(key)
        end
      end
      redirect_to redis_infos_path
    rescue => e
      puts "!!! Can not import file !!!"
    end
  end

  def configuration
    unless params[:param].nil?
      param = params[:param].intern
      value = params[:value]
      Redis.current.config(:set, param, value)
    end
    render :text => params[:value] 
  end

  def terminal
    add_breadcrumb "首页", "/redis_infos"
    add_breadcrumb "Redis 信息", "/redis_infos"
    add_breadcrumb "Redis 命令行"
    unless params[:command].nil?
      args = params[:command].split
      @cmd = args.shift.downcase.intern
      begin
        raise RuntimeError unless supported? @cmd
        if @cmd == :flushdb
          Record.destroy_all
        end
        @result = Redis.current.send @cmd, *args
        @result = empty_result if @result == []
      rescue ArgumentError
        @result = wrong_number_of_arguments_for @cmd
      rescue RuntimeError
        unknown @cmd
      rescue Errno::ECONNREFUSED
        connection_refused
      ensure
        render :partial => 'redis_infos/cli'
      end
    end
  end

  def load_redis
   #redis = Redis.current

   #loop do
   #  start = rand(10000)
   #  multi = rand(3)
   #  start.upto(multi * start) do |i|
   #    redis.set("key-#{i}", "abcdedghijklmnopqrstuvwxyz")
   #    Stringlist.create(:name => "key-#{i}")
   #  end
   #end
   #redirect_to redis_infos_path
  end

  private 
  def supported?(cmd)
    unsupported = [
      :eval,
      :psubscribe,
      :punsubscribe,
      :subscribe,
      :unsubscribe,
      :unwatch,
      :watch
    ]

    !unsupported.include? cmd
  end

  def empty_result
    '(empty list or set)'
  end

  def unknown(cmd)
    "(error) ERR unknown command '#{cmd}'"
  end

  def wrong_number_of_arguments_for(cmd)
    "(error) ERR wrong number of arguments for '#{cmd}' command"
  end
  

end
