class AddViewedToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :viewed, :boolean, null: false, default: false
  end
end
