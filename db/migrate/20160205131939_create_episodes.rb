class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.references :season, index: true, foreign_key: true
      t.integer :number
      t.date :air_date
      t.integer :tmdb_id

      t.timestamps null: false
    end
  end
end
