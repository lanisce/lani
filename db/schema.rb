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

ActiveRecord::Schema[7.0].define(version: 2025_01_27_170000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "budgets", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category", null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_budgets_on_active"
    t.index ["period_start", "period_end"], name: "index_budgets_on_period_start_and_period_end"
    t.index ["project_id", "category"], name: "index_budgets_on_project_id_and_category"
    t.index ["project_id"], name: "index_budgets_on_project_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.string "variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id", "variant_id"], name: "index_cart_items_on_cart_id_and_product_id_and_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["created_at"], name: "index_cart_items_on_created_at"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "medusa_id", null: false
    t.bigint "user_id", null: false
    t.bigint "project_id"
    t.string "currency", default: "usd", null: false
    t.string "status", default: "active"
    t.integer "subtotal_cents", default: 0
    t.integer "tax_total_cents", default: 0
    t.integer "shipping_total_cents", default: 0
    t.integer "total_cents", default: 0
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_carts_on_created_at"
    t.index ["medusa_id"], name: "index_carts_on_medusa_id", unique: true
    t.index ["project_id"], name: "index_carts_on_project_id"
    t.index ["status"], name: "index_carts_on_status"
    t.index ["user_id", "project_id", "status"], name: "index_carts_on_user_id_and_project_id_and_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.string "medusa_item_id"
    t.string "variant_id", null: false
    t.string "variant_title"
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.integer "total_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_order_items_on_created_at"
    t.index ["medusa_item_id"], name: "index_order_items_on_medusa_item_id"
    t.index ["order_id", "product_id"], name: "index_order_items_on_order_id_and_product_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "medusa_id", null: false
    t.bigint "user_id", null: false
    t.bigint "project_id"
    t.integer "display_id", null: false
    t.string "status", default: "pending", null: false
    t.string "fulfillment_status", default: "not_fulfilled"
    t.string "payment_status", default: "not_paid"
    t.integer "total_cents", default: 0, null: false
    t.integer "subtotal_cents", default: 0
    t.integer "tax_total_cents", default: 0
    t.integer "shipping_total_cents", default: 0
    t.string "currency", default: "usd", null: false
    t.datetime "medusa_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["display_id"], name: "index_orders_on_display_id"
    t.index ["fulfillment_status"], name: "index_orders_on_fulfillment_status"
    t.index ["medusa_id"], name: "index_orders_on_medusa_id", unique: true
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["project_id"], name: "index_orders_on_project_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id", "project_id"], name: "index_orders_on_user_id_and_project_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "medusa_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "currency", default: "usd", null: false
    t.integer "inventory_quantity", default: 0
    t.string "thumbnail_url"
    t.json "images", default: []
    t.json "variants", default: []
    t.string "collection_title"
    t.json "tags", default: []
    t.string "status", default: "draft"
    t.datetime "medusa_updated_at"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_title"], name: "index_products_on_collection_title"
    t.index ["created_at"], name: "index_products_on_created_at"
    t.index ["medusa_id"], name: "index_products_on_medusa_id", unique: true
    t.index ["price_cents"], name: "index_products_on_price_cents"
    t.index ["project_id"], name: "index_products_on_project_id"
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "project_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_memberships_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.bigint "owner_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "location_name"
    t.date "start_date"
    t.date "end_date"
    t.decimal "budget_limit", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_projects_on_latitude_and_longitude"
    t.index ["name"], name: "index_projects_on_name"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.date "due_date"
    t.datetime "completed_at"
    t.integer "estimated_hours"
    t.integer "actual_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["priority"], name: "index_tasks_on_priority"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "budget_id"
    t.bigint "user_id", null: false
    t.string "description", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_type", null: false
    t.date "transaction_date", null: false
    t.text "notes"
    t.string "receipt_url"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id", "transaction_type"], name: "index_transactions_on_budget_id_and_transaction_type"
    t.index ["budget_id"], name: "index_transactions_on_budget_id"
    t.index ["project_id", "transaction_date"], name: "index_transactions_on_project_id_and_transaction_date"
    t.index ["project_id"], name: "index_transactions_on_project_id"
    t.index ["transaction_date"], name: "index_transactions_on_transaction_date"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "onboarding_step"
    t.datetime "onboarding_started_at"
    t.datetime "onboarding_completed_at"
    t.text "bio"
    t.string "timezone", default: "UTC"
    t.json "notification_preferences", default: {}
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["onboarding_completed"], name: "index_users_on_onboarding_completed"
    t.index ["onboarding_step"], name: "index_users_on_onboarding_step"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "budgets", "projects"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "projects"
  add_foreign_key "carts", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "projects"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "projects"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "projects", "users", column: "owner_id"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users"
  add_foreign_key "transactions", "budgets"
  add_foreign_key "transactions", "projects"
  add_foreign_key "transactions", "users"
end
