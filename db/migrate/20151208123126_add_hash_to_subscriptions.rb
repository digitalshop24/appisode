class AddHashToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :options, :hstore, default: {}, null: false
  end
end
