class RedisInfosController < ApplicationController

  def index
    @info = Redis.current.info
  end

  def graph
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
