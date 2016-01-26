class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
			t.string :poster
      t.boolean :in_production
			t.integer :episode_count
			t.string :season_date
			t.string :episode_date
			t.string :three_episodes
      t.string :russian_name
			t.string :name			
			t.timestamps null: false
    end
  end
end
