class AddTvrageIdToShow < ActiveRecord::Migration
  def change
    add_column :shows, :tvrage_id, :integer
  end
end
