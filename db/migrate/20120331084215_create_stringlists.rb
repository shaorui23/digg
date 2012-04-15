class CreateStringlists < ActiveRecord::Migration
  def change
    create_table :stringlists do |t|
      t.string :name

      t.timestamps
    end
  end
end
