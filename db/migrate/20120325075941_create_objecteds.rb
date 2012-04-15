class CreateObjecteds < ActiveRecord::Migration
  def change
    create_table :objecteds do |t|

      t.timestamps
    end
  end
end
