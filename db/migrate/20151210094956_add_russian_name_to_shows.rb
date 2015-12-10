class AddRussianNameToShows < ActiveRecord::Migration
  def change
    add_column :shows, :russian_name, :string
  end
end
