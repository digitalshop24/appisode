class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.references :show, index: true, foreign_key: true
      t.integer :number
      t.string :poster
      t.integer :tmdb_id

      t.timestamps null: false
    end
  end
end
