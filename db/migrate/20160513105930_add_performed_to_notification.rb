class AddPerformedToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :performed, :boolean, null: false, default: false
  end
end
