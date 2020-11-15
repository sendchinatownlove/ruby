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

ActiveRecord::Schema.define(version: 2020_11_13_001940) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.boolean "active", default: false
    t.boolean "valid", default: true
    t.datetime "end_date", null: false
    t.string "description"
    t.string "gallery_image_urls", array: true
    t.bigint "location_id", null: false
    t.bigint "seller_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "distributor_id"
    t.integer "target_amount", default: 100000, null: false
    t.integer "price_per_meal", default: 500
    t.bigint "nonprofit_id"
    t.datetime "start_date"
    t.bigint "project_id"
    t.index ["distributor_id"], name: "index_campaigns_on_distributor_id"
    t.index ["location_id"], name: "index_campaigns_on_location_id"
    t.index ["nonprofit_id"], name: "index_campaigns_on_nonprofit_id"
    t.index ["project_id"], name: "index_campaigns_on_project_id"
    t.index ["seller_id"], name: "index_campaigns_on_seller_id"
  end

  create_table "campaigns_sellers_distributors", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "seller_id", null: false
    t.bigint "distributor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id", "distributor_id", "seller_id"], name: "campaigns_sellers_distributors_unique", unique: true
    t.index ["campaign_id"], name: "index_campaigns_sellers_distributors_on_campaign_id"
    t.index ["distributor_id"], name: "index_campaigns_sellers_distributors_on_distributor_id"
    t.index ["seller_id"], name: "index_campaigns_sellers_distributors_on_seller_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "email", null: false
    t.boolean "is_subscribed", default: true, null: false
    t.string "name"
    t.string "instagram"
    t.string "rewards_redemption_access_token"
    t.datetime "expires_at"
    t.index ["email"], name: "index_contacts_on_email", unique: true
  end

  create_table "delivery_options", force: :cascade do |t|
    t.string "url"
    t.string "phone_number"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["seller_id"], name: "index_delivery_options_on_seller_id"
  end

  create_table "delivery_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "icon_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "delivery_option_id"
    t.index ["delivery_option_id"], name: "index_delivery_types_on_delivery_option_id"
  end

  create_table "distributors", force: :cascade do |t|
    t.string "website_url"
    t.string "image_url"
    t.bigint "contact_id"
    t.string "name"
    t.index ["contact_id"], name: "index_distributors_on_contact_id"
  end

  create_table "donation_details", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_donation_details_on_item_id"
  end

  create_table "existing_events", force: :cascade do |t|
    t.string "idempotency_key"
    t.integer "event_type"
    t.index ["idempotency_key", "event_type"], name: "index_existing_events_on_idempotency_key_and_event_type", unique: true
  end

  create_table "fees", force: :cascade do |t|
    t.decimal "multiplier", default: "0.0"
    t.boolean "active", default: true
    t.bigint "seller_id", null: false
    t.index ["seller_id"], name: "index_fees_on_seller_id"
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
    t.bigint "recipient_id", null: false
    t.boolean "single_use", default: false, null: false
    t.index ["item_id"], name: "index_gift_card_details_on_item_id"
    t.index ["recipient_id"], name: "index_gift_card_details_on_recipient_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "seller_id"
    t.integer "item_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "payment_intent_id"
    t.boolean "refunded", default: false
    t.bigint "purchaser_id"
    t.bigint "campaign_id"
    t.bigint "project_id"
    t.index ["campaign_id"], name: "index_items_on_campaign_id"
    t.index ["payment_intent_id"], name: "index_items_on_payment_intent_id"
    t.index ["project_id"], name: "index_items_on_project_id"
    t.index ["purchaser_id"], name: "index_items_on_purchaser_id"
    t.index ["seller_id"], name: "index_items_on_seller_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address1", null: false
    t.string "address2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.bigint "seller_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone_number"
    t.string "neighborhood"
    t.string "borough"
    t.index ["seller_id"], name: "index_locations_on_seller_id"
  end

  create_table "lyft_rewards", force: :cascade do |t|
    t.string "code", null: false
    t.string "state", default: "new", null: false
    t.string "token"
    t.datetime "expires_at"
    t.bigint "contact_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contact_id"], name: "index_lyft_rewards_on_contact_id"
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

  create_table "nonprofits", force: :cascade do |t|
    t.string "name"
    t.string "logo_image_url"
    t.integer "contact_id"
    t.integer "fee_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "open_hours", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.time "open_time"
    t.time "close_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "open_day"
    t.integer "close_day"
    t.index ["seller_id"], name: "index_open_hours_on_seller_id"
  end

  create_table "participating_sellers", force: :cascade do |t|
    t.string "name"
    t.bigint "seller_id"
    t.string "stamp_url"
    t.string "tickets_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_lyft_sponsored", default: false
  end

  create_table "payment_intents", force: :cascade do |t|
    t.text "line_items"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "successful", default: false
    t.string "square_payment_id", null: false
    t.string "square_location_id", null: false
    t.string "receipt_url"
    t.bigint "purchaser_id"
    t.bigint "recipient_id"
    t.integer "lock_version"
    t.bigint "fee_id"
    t.bigint "campaign_id"
    t.text "metadata"
    t.bigint "project_id"
    t.index ["campaign_id"], name: "index_payment_intents_on_campaign_id"
    t.index ["fee_id"], name: "index_payment_intents_on_fee_id"
    t.index ["project_id"], name: "index_payment_intents_on_project_id"
    t.index ["purchaser_id"], name: "index_payment_intents_on_purchaser_id"
    t.index ["recipient_id"], name: "index_payment_intents_on_recipient_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "square_location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.string "square_refund_id"
    t.string "status"
    t.bigint "payment_intent_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_intent_id"], name: "index_refunds_on_payment_intent_id"
  end

  create_table "seller_translations", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.text "story"
    t.string "owner_name"
    t.text "summary"
    t.string "business_type"
    t.index ["locale"], name: "index_seller_translations_on_locale"
    t.index ["seller_id"], name: "index_seller_translations_on_seller_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.string "seller_id", null: false
    t.string "cuisine_name"
    t.boolean "accept_donations", default: true, null: false
    t.boolean "sell_gift_cards", default: false, null: false
    t.string "owner_image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "target_amount", default: 1000000
    t.string "hero_image_url"
    t.string "progress_bar_color"
    t.string "business_type"
    t.integer "num_employees"
    t.integer "founded_year"
    t.string "website_url"
    t.string "menu_url"
    t.string "square_location_id", null: false
    t.integer "cost_per_meal"
    t.string "gallery_image_urls", default: [], null: false, array: true
    t.string "logo_image_url"
    t.string "non_profit_location_id"
    t.string "gift_cards_access_token", default: "", null: false
    t.index ["gift_cards_access_token"], name: "index_sellers_on_gift_cards_access_token", unique: true
    t.index ["seller_id"], name: "index_sellers_on_seller_id"
  end

  create_table "sponsor_sellers", force: :cascade do |t|
    t.string "name"
    t.bigint "location_id"
    t.string "logo_url"
    t.string "reward"
    t.integer "reward_cost", default: 3, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reward_detail"
    t.boolean "active", default: true, null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "contact_id"
    t.string "ticket_id", null: false
    t.bigint "participating_seller_id", null: false
    t.bigint "sponsor_seller_id"
    t.date "redeemed_at"
    t.date "expiration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "printed", default: false, null: false
    t.datetime "associated_with_contact_at"
    t.index ["contact_id"], name: "index_tickets_on_contact_id"
    t.index ["participating_seller_id"], name: "index_tickets_on_participating_seller_id"
    t.index ["sponsor_seller_id"], name: "index_tickets_on_sponsor_seller_id"
  end

  add_foreign_key "campaigns", "locations"
  add_foreign_key "campaigns", "projects"
  add_foreign_key "campaigns", "sellers"
  add_foreign_key "campaigns_sellers_distributors", "campaigns"
  add_foreign_key "campaigns_sellers_distributors", "distributors"
  add_foreign_key "campaigns_sellers_distributors", "sellers"
  add_foreign_key "delivery_options", "sellers"
  add_foreign_key "delivery_types", "delivery_options"
  add_foreign_key "donation_details", "items"
  add_foreign_key "gift_card_amounts", "gift_card_details"
  add_foreign_key "gift_card_details", "contacts", column: "recipient_id"
  add_foreign_key "gift_card_details", "items"
  add_foreign_key "items", "campaigns"
  add_foreign_key "items", "contacts", column: "purchaser_id"
  add_foreign_key "items", "payment_intents"
  add_foreign_key "items", "sellers"
  add_foreign_key "locations", "sellers"
  add_foreign_key "lyft_rewards", "contacts"
  add_foreign_key "menu_items", "sellers"
  add_foreign_key "open_hours", "sellers"
  add_foreign_key "payment_intents", "campaigns"
  add_foreign_key "payment_intents", "contacts", column: "purchaser_id"
  add_foreign_key "payment_intents", "contacts", column: "recipient_id"
  add_foreign_key "payment_intents", "projects"
  add_foreign_key "refunds", "payment_intents"
  add_foreign_key "tickets", "contacts"
  add_foreign_key "tickets", "participating_sellers"
  add_foreign_key "tickets", "sponsor_sellers"
end
