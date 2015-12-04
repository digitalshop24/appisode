class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :text
    add_column :users, :number, :text
    add_column :users, :subscription, :boolean
  end
end
