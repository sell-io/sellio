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

ActiveRecord::Schema[8.1].define(version: 2026_08_17_230000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_favorites_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.datetime "boosted_until"
    t.bigint "category_id"
    t.string "city"
    t.string "condition"
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "expires_at"
    t.jsonb "extra_fields", default: {}
    t.boolean "featured"
    t.decimal "previous_price", precision: 10, scale: 2
    t.decimal "price"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "views"
    t.index ["category_id"], name: "index_listings_on_category_id"
    t.index ["extra_fields"], name: "index_listings_on_extra_fields", using: :gin
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.boolean "read", default: false
    t.bigint "recipient_id", null: false
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_messages_on_listing_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "offers", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "buyer_id", null: false
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.text "message"
    t.bigint "previous_offer_id"
    t.string "proposed_by", null: false
    t.bigint "seller_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_offers_on_buyer_id"
    t.index ["listing_id"], name: "index_offers_on_listing_id"
    t.index ["previous_offer_id"], name: "index_offers_on_previous_offer_id"
    t.index ["seller_id"], name: "index_offers_on_seller_id"
    t.index ["status"], name: "index_offers_on_status"
  end

  create_table "pending_payments", force: :cascade do |t|
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "kind", null: false
    t.bigint "listing_id"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["listing_id"], name: "index_pending_payments_on_listing_id"
    t.index ["token"], name: "index_pending_payments_on_token", unique: true
    t.index ["user_id"], name: "index_pending_payments_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.string "reason", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["listing_id"], name: "index_reports_on_listing_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.bigint "reviewed_user_id", null: false
    t.bigint "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_user_id"], name: "index_reviews_on_reviewed_user_id"
    t.index ["reviewer_id", "reviewed_user_id"], name: "index_reviews_on_reviewer_id_and_reviewed_user_id", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "rating_range"
  end

  create_table "saved_searches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_notified_at"
    t.string "name"
    t.jsonb "query_params", default: {}
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_saved_searches_on_user_id"
  end

  create_table "seller_follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "seller_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["seller_id"], name: "index_seller_follows_on_seller_id"
    t.index ["user_id", "seller_id"], name: "index_seller_follows_on_user_id_and_seller_id", unique: true
    t.index ["user_id"], name: "index_seller_follows_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "banned_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "free_boosts_reset_at"
    t.integer "free_boosts_used", default: 0, null: false
    t.boolean "is_verified", default: false, null: false
    t.string "location"
    t.string "name"
    t.string "phone"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "favorites", "listings"
  add_foreign_key "favorites", "users"
  add_foreign_key "messages", "listings"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "offers", "listings"
  add_foreign_key "offers", "offers", column: "previous_offer_id"
  add_foreign_key "offers", "users", column: "buyer_id"
  add_foreign_key "offers", "users", column: "seller_id"
  add_foreign_key "pending_payments", "listings"
  add_foreign_key "pending_payments", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "reports", "listings"
  add_foreign_key "reports", "users"
  add_foreign_key "reviews", "users", column: "reviewed_user_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "saved_searches", "users"
  add_foreign_key "seller_follows", "users"
  add_foreign_key "seller_follows", "users", column: "seller_id"
end
