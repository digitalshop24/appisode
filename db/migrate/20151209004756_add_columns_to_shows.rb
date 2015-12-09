class AddColumnsToShows < ActiveRecord::Migration
  def change
    add_column :shows, :season_date, :text
    add_column :shows, :episode_date, :text
    add_column :shows, :three_episode, :text
  end
end
