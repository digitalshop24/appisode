class CreateNotificationMessages < ActiveRecord::Migration
  def change
    create_table :notification_messages do |t|
      t.string :key
      t.references :show, index: true, foreign_key: true
      t.string :message_ru
      t.string :message_en

      t.timestamps null: false
    end
    add_index :notification_messages, [:key, :show_id], unique: true
  end
end
