module ApplicationHelper
  def need_introduction?
    controllers = ["stringlists","products","objecteds","records"]
    controllers.include? params[:controller] ? false : true
  end

  def redis_config
    pretty_config = {}
    Redis.current.config(:get, "*").each do |k, v|
      pretty_config[k] = v
    end
    pretty_config
  end
end
