# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_23_234913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donation_details", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_donation_details_on_item_id"
  end

  create_table "gift_card_amounts", force: :cascade do |t|
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "gift_card_detail_id", null: false
    t.index ["gift_card_detail_id"], name: "index_gift_card_amounts_on_gift_card_detail_id"
  end

  create_table "gift_card_details", force: :cascade do |t|
    t.string "gift_card_id"
    t.string "receipt_id"
    t.date "expiration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "item_id", null: false
    t.string "seller_gift_card_id"
    t.index ["item_id"], name: "index_gift_card_details_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "email"
    t.bigint "seller_id", null: false
    t.integer "item_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "payment_intent_id", null: false
    t.index ["payment_intent_id"], name: "index_items_on_payment_intent_id"
    t.index ["seller_id"], name: "index_items_on_seller_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address1", null: false
    t.string "address2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone_number"
    t.index ["seller_id"], name: "index_locations_on_seller_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "amount"
    t.string "image_url"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["seller_id"], name: "index_menu_items_on_seller_id"
  end

  create_table "payment_intents", force: :cascade do |t|
    t.string "stripe_id"
    t.string "email"
    t.text "line_items"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "successful", default: false
    t.string "square_payment_id"
    t.string "square_location_id"
    t.string "email_text"
  end

  create_table "sellers", force: :cascade do |t|
    t.string "seller_id", null: false
    t.string "cuisine_name"
    t.string "name"
    t.text "story"
    t.boolean "accept_donations", default: true, null: false
    t.boolean "sell_gift_cards", default: false, null: false
    t.string "owner_name"
    t.string "owner_image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "target_amount", default: 1000000
    t.text "summary"
    t.string "hero_image_url"
    t.string "progress_bar_color"
    t.string "business_type"
    t.integer "num_employees"
    t.integer "founded_year"
    t.string "website_url"
    t.string "menu_url"
    t.index ["seller_id"], name: "index_sellers_on_seller_id"
  end

  add_foreign_key "donation_details", "items"
  add_foreign_key "gift_card_amounts", "gift_card_details"
  add_foreign_key "gift_card_details", "items"
  add_foreign_key "items", "payment_intents"
  add_foreign_key "items", "sellers"
  add_foreign_key "locations", "sellers"
  add_foreign_key "menu_items", "sellers"
end
