# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160614112712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "episodes", force: :cascade do |t|
    t.integer  "season_id"
    t.integer  "number"
    t.date     "air_date"
    t.integer  "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "episodes", ["season_id"], name: "index_episodes_on_season_id", using: :btree

  create_table "notification_messages", force: :cascade do |t|
    t.string   "key"
    t.integer  "show_id"
    t.string   "message_ru"
    t.string   "message_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notification_messages", ["key", "show_id"], name: "index_notification_messages_on_key_and_show_id", unique: true, using: :btree
  add_index "notification_messages", ["show_id"], name: "index_notification_messages_on_show_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "subscription_id"
    t.date     "date"
    t.string   "message"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "performed",       default: false, null: false
    t.boolean  "viewed",          default: false, null: false
  end

  add_index "notifications", ["subscription_id"], name: "index_notifications_on_subscription_id", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.integer  "show_id"
    t.integer  "number"
    t.string   "poster"
    t.integer  "tmdb_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "number_of_episodes"
  end

  add_index "seasons", ["show_id"], name: "index_seasons_on_show_id", using: :btree

# Could not dump table "shows" because of following StandardError
#   Unknown type 'show_status' for column 'status'

# Could not dump table "subscriptions" because of following StandardError
#   Unknown type 'subtype' for column 'subtype'

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "confirmation"
    t.string   "phone"
    t.string   "auth_token",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "language"
  end

  add_foreign_key "devices", "users"
  add_foreign_key "episodes", "seasons"
  add_foreign_key "notification_messages", "shows"
  add_foreign_key "notifications", "subscriptions"
  add_foreign_key "seasons", "shows"
  add_foreign_key "subscriptions", "episodes", column: "next_notification_episode_id"
  add_foreign_key "subscriptions", "episodes", column: "previous_notification_episode_id"
end
