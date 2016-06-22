class AddIdsToShow < ActiveRecord::Migration
  def change
    add_column :shows, :tvmaze_id, :integer
    add_column :shows, :trakt_id, :integer
    add_column :shows, :tvdb_id, :integer
    add_column :shows, :imdb_id, :string
  end
end
