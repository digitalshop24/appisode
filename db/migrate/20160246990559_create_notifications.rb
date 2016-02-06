class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :subscription, index: true, foreign_key: true
      t.date :date
      t.string :message

      t.timestamps null: false
    end
  end
end
