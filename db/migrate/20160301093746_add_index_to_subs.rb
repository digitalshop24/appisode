class AddIndexToSubs < ActiveRecord::Migration
  def change
  	add_index :subscriptions, [:user_id, :show_id], unique: true
  end
end
