class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
			t.string :poster
      t.boolean :in_production
			t.integer :episode_count
			t.date :season_date
			t.date :episode_date
			t.date :three_episodes
      t.string :russian_name
			t.string :name			
			t.timestamps null: false
    end
  end
end
