class RemoveColumnEpisodeIdFromSubscription < ActiveRecord::Migration
  def change
  	remove_column :subscriptions, :episode_id
  end
end
