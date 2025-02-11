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

ActiveRecord::Schema[7.2].define(version: 2025_01_11_161558) do
  create_table "account_tiers", force: :cascade do |t|
    t.string "name"
    t.integer "budget_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_account_tiers_on_budget_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.integer "account_tier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_tier_id"], name: "index_accounts_on_account_tier_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "name"
    t.integer "timeperiod_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timeperiod_id"], name: "index_budgets_on_timeperiod_id"
  end

  create_table "timeperiods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "budget_id", null: false
    t.integer "source_id", null: false
    t.integer "dest_id", null: false
    t.string "file"
    t.integer "row"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_transfers_on_budget_id"
    t.index ["dest_id"], name: "index_transfers_on_dest_id"
    t.index ["source_id"], name: "index_transfers_on_source_id"
  end

  add_foreign_key "account_tiers", "budgets"
  add_foreign_key "accounts", "account_tiers"
  add_foreign_key "budgets", "timeperiods"
  add_foreign_key "transfers", "accounts", column: "dest_id"
  add_foreign_key "transfers", "accounts", column: "source_id"
  add_foreign_key "transfers", "budgets"
end
