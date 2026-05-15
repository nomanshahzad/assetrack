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

ActiveRecord::Schema[8.1].define(version: 2026_05_15_171002) do
  create_table "asset_items", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.datetime "created_at", null: false
    t.boolean "is_consumable", default: false, null: false
    t.boolean "is_custody", default: false, null: false
    t.boolean "is_new", default: false, null: false
    t.boolean "is_used", default: false, null: false
    t.string "item_details"
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_items_on_asset_id"
  end

  create_table "assets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "delivered_by_date"
    t.string "delivered_by_name"
    t.date "handover_date"
    t.boolean "is_consumable", default: false, null: false
    t.boolean "is_custody", default: false, null: false
    t.text "notes"
    t.date "received_by_date"
    t.string "received_by_name"
    t.string "receiver_branch_department"
    t.string "receiver_employee_number"
    t.string "receiver_name"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "asset_items", "assets"
  add_foreign_key "sessions", "users"
end
