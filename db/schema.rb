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

ActiveRecord::Schema.define(version: 20151204004322) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bikes", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",                  limit: nil
    t.string   "image_file_name",       limit: nil
    t.string   "image_content_type",    limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "price"
    t.integer  "year"
    t.string   "bike_class",            limit: nil
    t.string   "bike_type",             limit: nil
    t.float    "weight"
    t.text     "description"
    t.string   "frame_type",            limit: nil
    t.string   "handlebar",             limit: nil
    t.string   "chain",                 limit: nil
    t.string   "fork",                  limit: nil
    t.boolean  "pomp"
    t.string   "rims",                  limit: nil
    t.string   "saddle",                limit: nil
    t.boolean  "roga"
    t.string   "grips",                 limit: nil
    t.boolean  "light"
    t.string   "carriage",              limit: nil
    t.boolean  "basket"
    t.string   "shifters",              limit: nil
    t.string   "handlebar_type",        limit: nil
    t.boolean  "luggage_rack"
    t.boolean  "footboard"
    t.string   "tires",                 limit: nil
    t.string   "fork_type",             limit: nil
    t.string   "saddle_type",           limit: nil
    t.string   "frame_color",           limit: nil, default: [],                array: true
    t.boolean  "chain_protection"
    t.string   "shifters_type",         limit: nil
    t.string   "pedal_type",            limit: nil
    t.float    "handlebar_width"
    t.float    "tires_width"
    t.boolean  "rear_fender"
    t.string   "grips_model",           limit: nil
    t.boolean  "double_rims"
    t.float    "wheels_diameter"
    t.string   "rear_brake",            limit: nil
    t.string   "rear_hub",              limit: nil
    t.string   "frame_material",        limit: nil
    t.boolean  "folding_frame"
    t.boolean  "front_fender"
    t.string   "front_hub",             limit: nil
    t.string   "front_brake",           limit: nil
    t.string   "crank_system",          limit: nil
    t.string   "amortization_type",     limit: nil
    t.string   "transmission_type",     limit: nil
    t.boolean  "fork_locking"
    t.string   "rims_material",         limit: nil
    t.string   "pedal_material",        limit: nil
    t.string   "absorber_length",       limit: nil
    t.boolean  "saddle_amortization"
    t.boolean  "horn"
    t.boolean  "rear_absorber"
    t.string   "tread",                 limit: nil
    t.float    "fork_rod_diameter"
    t.string   "rear_brake_type",       limit: nil
    t.boolean  "rearview_mirror"
    t.string   "ratchet",               limit: nil
    t.string   "rear_derailleur",       limit: nil
    t.integer  "speeds_number"
    t.string   "front_break_type",      limit: nil
    t.string   "front_derailleur",      limit: nil
    t.float    "brake_disks_diameter"
    t.integer  "stars_number_cassette"
    t.integer  "stars_number_system"
    t.integer  "teeth_number_cassette"
    t.integer  "teeth_number_system"
    t.boolean  "display",                           default: true
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "hit"
  end

  add_index "bikes", ["manufacturer_id"], name: "index_bikes_on_manufacturer_id", using: :btree

  create_table "electriccars", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",               limit: nil
    t.integer  "price"
    t.string   "age",                limit: nil
    t.boolean  "remote_control"
    t.integer  "max_speed"
    t.string   "battery",            limit: nil
    t.string   "engine",             limit: nil
    t.string   "work_time",          limit: nil
    t.string   "charging_time",      limit: nil
    t.integer  "max_weight"
    t.integer  "weight"
    t.string   "sizes",              limit: nil
    t.string   "light",              limit: nil
    t.boolean  "seat_belt"
    t.boolean  "rearview_mirror"
    t.text     "description"
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "display"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "hit"
  end

  add_index "electriccars", ["manufacturer_id"], name: "index_electriccars_on_manufacturer_id", using: :btree

  create_table "galleries", force: true do |t|
    t.integer  "galleryable_id"
    t.string   "galleryable_type", limit: nil
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "galleries", ["galleryable_type", "galleryable_id"], name: "index_galleries_on_galleryable_type_and_galleryable_id", using: :btree

  create_table "icesleds", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",               limit: nil
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "description"
    t.string   "material",           limit: nil
    t.boolean  "handles"
    t.integer  "length"
    t.boolean  "display",                        default: true
    t.integer  "price"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "hit"
  end

  add_index "icesleds", ["manufacturer_id"], name: "index_icesleds_on_manufacturer_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "gallery_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "images", ["gallery_id"], name: "index_images_on_gallery_id", using: :btree

  create_table "kickscooters", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",                 limit: nil
    t.integer  "price"
    t.text     "description"
    t.string   "image_file_name",      limit: nil
    t.string   "image_content_type",   limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "use",                  limit: nil
    t.boolean  "electric_drive"
    t.integer  "max_weight"
    t.integer  "wheels_number"
    t.integer  "wheels_diameter"
    t.integer  "wheels_thickness"
    t.string   "wheels_material",      limit: nil
    t.string   "wheels_hardness",      limit: nil
    t.boolean  "inflatable_wheels"
    t.string   "bearings",             limit: nil
    t.string   "platform_material",    limit: nil
    t.boolean  "folding"
    t.boolean  "seat"
    t.boolean  "amortization"
    t.boolean  "front_break"
    t.boolean  "rear_break"
    t.boolean  "tilt_handle_control"
    t.boolean  "wheels_luminodiodes"
    t.integer  "min_handlebar_height"
    t.integer  "max_handlebar_height"
    t.integer  "platform_length"
    t.integer  "platform_width"
    t.integer  "length"
    t.float    "weight"
    t.boolean  "horn"
    t.boolean  "basket"
    t.boolean  "footboard"
    t.boolean  "belt"
    t.boolean  "display",                          default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "hit"
  end

  add_index "kickscooters", ["manufacturer_id"], name: "index_kickscooters_on_manufacturer_id", using: :btree

  create_table "kidsbikes", force: true do |t|
    t.string   "name",                 limit: nil
    t.integer  "manufacturer_id"
    t.string   "image_file_name",      limit: nil
    t.string   "image_content_type",   limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "price"
    t.string   "recommended_age",      limit: nil
    t.string   "use",                  limit: nil
    t.float    "weight"
    t.string   "seat",                 limit: nil
    t.boolean  "seat_belts"
    t.boolean  "handle"
    t.boolean  "control_handle"
    t.boolean  "safety_rim"
    t.boolean  "visor"
    t.boolean  "music_unit"
    t.string   "frame_material",       limit: nil
    t.boolean  "folding_frame"
    t.string   "frame_color",          limit: nil, default: [],                array: true
    t.string   "fork",                 limit: nil
    t.string   "fork_type",            limit: nil
    t.integer  "speeds_number"
    t.string   "rear_derailleur",      limit: nil
    t.string   "shifters",             limit: nil
    t.string   "shifters_type",        limit: nil
    t.string   "front_brake_type",     limit: nil
    t.string   "rear_brake_type",      limit: nil
    t.integer  "wheels_number"
    t.float    "wheels_diameter"
    t.float    "front_wheel_diameter"
    t.boolean  "attached_wheels"
    t.string   "wheels_type",          limit: nil
    t.boolean  "rear_wheels_stopper"
    t.boolean  "raincoat"
    t.boolean  "front_fender"
    t.boolean  "rear_fender"
    t.boolean  "chain_protection"
    t.boolean  "luggage_rack"
    t.boolean  "rearview_mirror"
    t.boolean  "horn"
    t.boolean  "basket"
    t.boolean  "bag"
    t.boolean  "flag"
    t.boolean  "footboard"
    t.boolean  "light"
    t.boolean  "pomp"
    t.boolean  "display",                          default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "description"
    t.integer  "kid_height"
    t.string   "wheels_material",      limit: nil
    t.boolean  "sloping_backrest"
    t.boolean  "hit"
  end

  add_index "kidsbikes", ["manufacturer_id"], name: "index_kidsbikes_on_manufacturer_id", using: :btree

  create_table "manufacturers", force: true do |t|
    t.string   "name",       limit: nil
    t.string   "category",   limit: nil
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "series", force: true do |t|
    t.integer "user_id",   null: false
    t.integer "film_id",   null: false
    t.text    "title",     null: false
    t.text    "logo"
    t.text    "date"
    t.text    "full_date"
    t.text    "second"
    t.text    "third"
  end

  create_table "skis", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",               limit: nil
    t.integer  "price"
    t.boolean  "poles"
    t.boolean  "grid"
    t.integer  "size"
    t.text     "description"
    t.boolean  "display"
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "hit"
  end

  add_index "skis", ["manufacturer_id"], name: "index_skis_on_manufacturer_id", using: :btree

  create_table "sleds", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",                limit: nil
    t.string   "image_file_name",     limit: nil
    t.string   "image_content_type",  limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "price"
    t.text     "description"
    t.integer  "runners_width"
    t.boolean  "seat_belt"
    t.string   "seat_belt_type",      limit: nil
    t.boolean  "folding_visor"
    t.string   "folding_visor_type",  limit: nil
    t.boolean  "bag"
    t.boolean  "flicker"
    t.boolean  "backrest_adjustment"
    t.string   "color",               limit: nil, default: [],                array: true
    t.boolean  "transport_wheel"
    t.boolean  "legs_case"
    t.boolean  "display",                         default: true
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "handle"
    t.string   "recommended_age",     limit: nil
    t.boolean  "hit"
  end

  add_index "sleds", ["manufacturer_id"], name: "index_sleds_on_manufacturer_id", using: :btree

  create_table "snowrolls", force: true do |t|
    t.integer  "manufacturer_id"
    t.string   "name",               limit: nil
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "description"
    t.boolean  "display",                        default: true
    t.integer  "price"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "seats_number",       limit: nil
    t.integer  "carrying"
    t.boolean  "hit"
  end

  add_index "snowrolls", ["manufacturer_id"], name: "index_snowrolls_on_manufacturer_id", using: :btree

  create_table "tubings", force: true do |t|
    t.string   "name",               limit: nil
    t.integer  "manufacturer_id"
    t.string   "bottom_material",    limit: nil
    t.string   "top_material",       limit: nil
    t.integer  "diameter"
    t.string   "handles_type",       limit: nil
    t.boolean  "tow_rope"
    t.text     "description"
    t.boolean  "display",                        default: true
    t.integer  "price"
    t.string   "image_file_name",    limit: nil
    t.string   "image_content_type", limit: nil
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "hit"
  end

  add_index "tubings", ["manufacturer_id"], name: "index_tubings_on_manufacturer_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "email"
    t.text     "number"
    t.boolean  "subscription"
  end

end
