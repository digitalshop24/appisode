class AddPopularityToShows < ActiveRecord::Migration
  def change
  	add_column :shows, :popularity, :float, default: 1000
  end
end
