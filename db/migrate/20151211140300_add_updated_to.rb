class AddUpdatedTo < ActiveRecord::Migration
  def change
    add_column :users, :updated, :datetime
  end
end
