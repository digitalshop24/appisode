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

ActiveRecord::Schema.define(version: 20151214125323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "series", force: :cascade do |t|
    t.integer "user_id",   null: false
    t.integer "film_id",   null: false
    t.integer "title",     null: false
    t.text    "logo"
    t.text    "date"
    t.text    "full_date"
    t.text    "second"
    t.text    "third"
  end

  create_table "shows", force: :cascade do |t|
    t.string   "poster"
    t.boolean  "in_production"
    t.integer  "episode_count"
    t.string   "additional_field"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "season_date"
    t.text     "episode_date"
    t.text     "three_episode"
    t.string   "russian_name"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "serial_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.hstore   "options",    default: {}, null: false
  end

  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.text     "email"
    t.text     "number"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "updated"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
  end

  add_foreign_key "identities", "users"
end
