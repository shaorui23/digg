# coding: utf-8  
class RedisInfosController < ApplicationController

  def index
    @info = Redis.current.info
    add_breadcrumb "首页", "/redis_infos"
    add_breadcrumb "Redis 信息", "/redis_infos"
    $data = []

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
      temp.push (num/Redis.current.keys.count.to_f)
      $data.push(temp)
    end
  end

  def graph
    add_breadcrumb "首页", "/redis_infos"
    add_breadcrumb "Redis 信息", "/redis_infos"
    add_breadcrumb "Redis 图表"
    @info = Redis.current.info
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
      system(%[cat ~/Desktop/test.json | redis-load])
      redirect_to redis_infos_path
    rescue => e
      puts "!!! Can not import file !!!"
    end
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
        @result = Redis.current.send @cmd, *args
        @result = empty_result if @result == []
        render :partial => 'redis_infos/cli'
      rescue ArgumentError
        wrong_number_of_arguments_for @cmd
      rescue RuntimeError
        unknown @cmd
      rescue Errno::ECONNREFUSED
        connection_refused
      end
    end
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
