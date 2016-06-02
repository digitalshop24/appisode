class AddTagsToShow < ActiveRecord::Migration
  def change
    add_column :shows, :tags, :string, array: true, null: false, default: []
  end
end
