class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
			t.references :show
      t.references :episode
      t.integer :subtype
			t.references :user, index: true
      t.boolean :active
      
      t.timestamps null: false
    end
  end
end
