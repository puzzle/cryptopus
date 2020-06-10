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

ActiveRecord::Schema.define(version: 2020_06_02_170103) do

  create_table "accounts", force: :cascade do |t|
    t.string "accountname", limit: 70, default: "", null: false
    t.integer "folder_id", default: 0, null: false
    t.text "description"
    t.binary "username"
    t.binary "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
    t.index ["tag"], name: "index_accounts_on_tag"
  end

  create_table "file_entries", force: :cascade do |t|
    t.integer "account_id", default: 0, null: false
    t.text "description"
    t.binary "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "filename", null: false
    t.text "content_type", null: false
  end

  create_table "folders", force: :cascade do |t|
    t.string "name", limit: 40, default: "", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id", default: 0, null: false
  end

  create_table "logs", force: :cascade do |t|
    t.string "output"
    t.string "status"
    t.string "log_type"
    t.integer "executer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recryptrequests", force: :cascade do |t|
    t.integer "user_id", default: 0, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "type", null: false
  end

  create_table "teammembers", force: :cascade do |t|
    t.integer "team_id", default: 0, null: false
    t.binary "password", null: false
    t.integer "user_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", limit: 40, default: "", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true, null: false
    t.boolean "private", default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.text "public_key", null: false
    t.binary "private_key", null: false
    t.binary "password"
    t.integer "ldap_uid"
    t.datetime "last_login_at"
    t.string "username"
    t.string "givenname"
    t.string "surname"
    t.string "auth", default: "db", null: false
    t.string "preferred_locale", default: "en", null: false
    t.boolean "locked", default: false
    t.datetime "last_failed_login_attempt_at"
    t.integer "failed_login_attempts", default: 0, null: false
    t.string "last_login_from"
    t.string "type"
    t.integer "human_user_id"
    t.text "options"
    t.integer "role", default: 0, null: false
  end

end
