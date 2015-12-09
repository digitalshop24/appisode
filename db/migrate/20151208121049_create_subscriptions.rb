class CreateSubscriptions < ActiveRecord::Migration
  def change
    remove_column :users, :subscription_id
    create_table :subscriptions do |t|
      t.integer :serial_id
      t.timestamps
    end
  end
end
