class AddNumberOfEpisodesToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :number_of_episodes, :integer
  end
end
