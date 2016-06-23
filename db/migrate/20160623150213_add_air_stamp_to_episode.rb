class AddAirStampToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :air_stamp, :datetime
  end
end
