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

ActiveRecord::Schema.define(version: 20160301093746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episodes", force: :cascade do |t|
    t.integer  "season_id"
    t.integer  "number"
    t.date     "air_date"
    t.integer  "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "episodes", ["season_id"], name: "index_episodes_on_season_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "subscription_id"
    t.date     "date"
    t.string   "message"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "notifications", ["subscription_id"], name: "index_notifications_on_subscription_id", using: :btree

  create_table "seasons", force: :cascade do |t|
    t.integer  "show_id"
    t.integer  "number"
    t.string   "poster"
    t.integer  "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "seasons", ["show_id"], name: "index_seasons_on_show_id", using: :btree

  create_table "shows", force: :cascade do |t|
    t.string   "poster"
    t.boolean  "in_production"
    t.string   "name"
    t.string   "russian_name"
    t.integer  "tmdb_id"
    t.integer  "number_of_seasons"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "show_id"
    t.integer  "episode_id"
    t.integer  "subtype"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["user_id", "show_id"], name: "index_subscriptions_on_user_id_and_show_id", unique: true, using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "confirmation"
    t.string   "phone"
    t.string   "key"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "token"
  end

  add_foreign_key "episodes", "seasons"
  add_foreign_key "notifications", "subscriptions"
  add_foreign_key "seasons", "shows"
end
