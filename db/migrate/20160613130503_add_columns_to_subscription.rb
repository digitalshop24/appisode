class AddColumnsToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :episodes_interval, :integer
    add_column :subscriptions, :previous_notification_episode_id, :integer
    add_column :subscriptions, :next_notification_episode_id, :integer
  	add_foreign_key :subscriptions, :episodes, column: :next_notification_episode_id
  	add_foreign_key :subscriptions, :episodes, column: :previous_notification_episode_id
  end
end
