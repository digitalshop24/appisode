class ChangeSubscriptionSubtypePresentation < ActiveRecord::Migration
  def up
    change_column :subscriptions, :subtype, :string
    Subscription.where(subtype: [0, 1]).update_all(subtype: 'episode')
    Subscription.where(subtype: [2]).update_all(subtype: 'season')
    change_column :subscriptions, :subtype, 'subtype USING subtype::subtype', null: false
  end
  def down
    change_column :subscriptions, :subtype, :string
    Subscription.where(subtype: 'episode').update_all(subtype: '0')
    Subscription.where(subtype: 'season').update_all(subtype: '2')
    change_column :subscriptions, :subtype, 'integer USING subtype::integer'
  end
end
