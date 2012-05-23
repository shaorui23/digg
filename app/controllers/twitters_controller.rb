class TwittersController < ApplicationController
  def init_data
    redis = Redis.current
    init_user(redis)
    init_followers(redis)
    init_post(redis)
    redirect_to redis_infos_path
  end

  def add_post
    redis = Redis.current
    post_id = redis.incr("global:NextPostId")   #至少随机生成50条post，用于分配给6个用户
    redis.set("post:#{post_id}", params[:post])
    redis.rpush("posts", post_id)
    redis.sadd("user:id:#{params[:id]}:posts", post_id)
    redis.smembers("user:id:#{params[:id]}:followers").each do |follower|   #添加该帖子给粉丝
      redis.sadd("user:id:#{follower}:mentions", post_id)
    end
    redirect_to twitters_path
  end

  def add_friend
    redis = Redis.current
    redis.sadd("user:id:#{params[:self_id]}:followees", params[:followee_id])
    redis.sadd("user:id:#{params[:followee_id]}:followers", params[:self_id] )
    redis.smembers("user:id:#{params[:followee_id]}:posts").each do |post|   #添加你关注的用户的帖子给本身
      redis.sadd("user:id:#{params[:self_id]}:mentions", post)
    end
    redirect_to twitters_path
  end

  def remove_friend
    redis = Redis.current
    redis.srem("user:id:#{params[:self_id]}:followees", params[:follower_id])
    redis.srem("user:id:#{params[:follower_id]}:followers", params[:self_id])
    remove_ids = redis.smembers("user:id:#{params[:follower_id]}:posts")
    remove_ids.each do |id|
      redis.srem("user:id:#{params[:self_id]}:mentions", id) #移除之前关注的人的微博
    end
    redirect_to twitters_path
  end

  def random_num ids, id
    rand = rand(ids.size)
    temp = ids.slice(rand)
    if id != temp
      temp
    else
      temp = ids.slice(rand+1)
    end
  end

  private

  def init_user(redis)
    Product.create(:name => "users")
    Stringlist.create(:name => "user:uid")
    redis.set("user:uid", 1000)
    username = %W[A B C D E F]

    username.each do |name|
      user_id = Redis.current.incr("user:uid") 
      redis.set("user:id:#{user_id}:username", name)

      a = Stringlist.create(:name => "user:id:#{user_id}:username")
      a.redis_value = name
      b = Stringlist.create(:name => "user:username:#{name}")
      b.redis_value = user_id
      redis.rpush("users", user_id)
    end
  end

  def init_followers(redis)
    user_ids = redis.lrange("users", 0, -1)                #["1001", "1002", "1003", "1004", "1005", "1006"]

    user_ids.each do |id|
      Redisset.create(:name => "user:id:#{id}:followees")
      Redisset.create(:name => "user:id:#{id}:followers")
    end

    user_ids.each do |id|
      5.times do
        temp_id = random_num(user_ids,id)
        redis.sadd("user:id:#{id}:followees", temp_id)
        redis.sadd("user:id:#{temp_id}:followers", id )
      end
    end
  end

  def init_post(redis)
    Product.create(:name => "posts")
    Stringlist.create(:name => "global:NextPostId")
    redis.set("global:NextPostId", 1000)   #更新post的id，使其唯一

    posts = []
    username = %W[A B C D E F]
    username.each do |name|
      1.upto(3) do |i|
        posts.push("This is user " + name + "'s No." + i.to_s + " twitter!")
      end
    end
    posts.each do |post|
      post_id = redis.incr("global:NextPostId")   #至少随机生成50条post，用于分配给6个用户
      redis.set("post:#{post_id}", post)
      redis.rpush("posts", post_id)
    end

    user_ids = redis.lrange("users", 0, -1)
    user_ids.each {|id| Redisset.create(:name => "user:id:#{id}:posts"); Redisset.create(:name => "user:id:#{id}:mentions") }

    user_ids.each_with_index do |id, index|
      #TODO
      #twitter = posts.slice(index*3, 3)  #这里应该是存post:post_id
      twitter = redis.lrange("posts", index*3, 2+index*3)
      twitter.each do |t|
        redis.sadd("user:id:#{id}:posts", t)    #添加该帖子给当前用户
      end

      Redis.current.smembers("user:id:#{id}:followers").each do |follower|   #添加该帖子给粉丝
        twitter.each do |t|
          redis.sadd("user:id:#{follower}:mentions", t)
        end
      end
    end
  end

end
