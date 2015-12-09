class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :poster
      t.boolean :in_production
      t.integer :episode_count
      t.string :additional_field
      t.timestamps
    end
  end
end
