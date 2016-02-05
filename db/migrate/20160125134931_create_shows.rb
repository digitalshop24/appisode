class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
			t.string :poster
      t.boolean :in_production
			t.string :name			
      t.string :russian_name
      t.integer :tmdb_id
      t.integer :number_of_seasons
      
			t.timestamps null: false
    end
  end
end
