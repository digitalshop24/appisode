class AddColumnsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :key, :string
  end
end