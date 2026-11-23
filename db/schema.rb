# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_23_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availability_blocks", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.index ["venue_id"], name: "index_availability_blocks_on_venue_id"
    t.check_constraint "end_at > start_at", name: "availability_blocks_time_order"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "venue_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["venue_id"], name: "index_bookings_on_venue_id"
    t.check_constraint "end_at > start_at", name: "bookings_time_order"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2, 3])", name: "bookings_valid_status"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "venue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "venue_id"], name: "index_favorites_on_user_id_and_venue_id", unique: true
    t.index ["venue_id"], name: "index_favorites_on_venue_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.bigint "user_id", null: false
    t.integer "rating", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "booking_id"
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.index ["venue_id"], name: "index_reviews_on_venue_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_range"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.text "description"
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.boolean "availability_configured", default: false, null: false
    t.index ["city_id"], name: "index_venues_on_city_id"
    t.check_constraint "hourly_rate >= 0::numeric", name: "venues_hourly_rate_nonnegative"
  end

  add_foreign_key "availability_blocks", "venues"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "venues"
  add_foreign_key "favorites", "users"
  add_foreign_key "favorites", "venues"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "users"
  add_foreign_key "reviews", "venues"
  add_foreign_key "venues", "cities"
end
