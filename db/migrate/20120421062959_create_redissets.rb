class CreateRedissets < ActiveRecord::Migration
  def change
    create_table :redissets do |t|

      t.timestamps
    end
  end
end
