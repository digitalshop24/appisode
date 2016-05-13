class ChangesOfUserModel < ActiveRecord::Migration
  def change
  	change_column :users, :key, :string, null: false
  	rename_column :users, :key, :auth_token
  	remove_column :users, :token
  end
end
