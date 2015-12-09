class AddUserRefToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :user, index: true
  end
end
