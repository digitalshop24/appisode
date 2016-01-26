class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
			t.integer :show_id
			t.boolean :episode
      t.boolean :three_episodes
      t.boolean :season
			t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
