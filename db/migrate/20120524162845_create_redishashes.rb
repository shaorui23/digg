class CreateRedishashes < ActiveRecord::Migration
  def change
    create_table :redishashes do |t|

      t.timestamps
    end
  end
end
