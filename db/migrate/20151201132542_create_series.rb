class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.integer :user_id, null: false
      t.integer :film_id, null: false
      t.integer :title, null: false
      t.text :logo
      t.text :date
    end
  end
end
