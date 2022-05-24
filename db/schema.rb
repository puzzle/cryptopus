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

ActiveRecord::Schema[7.0].define(version: 2022_05_17_131300) do
  create_table "encryptables", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.integer "folder_id"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tag"
    t.string "type", default: "Account::Credentials", null: false
    t.text "encrypted_data", limit: 16777215
    t.integer "credential_id"
    t.text "content_type"
    t.binary "transfer_password"
    t.integer "receiver_id"
    t.string "encryption_algorithm", default: "AES256", null: false
    t.index ["description"], name: "index_encryptables_on_description"
    t.index ["name"], name: "index_encryptables_on_name"
    t.index ["tag"], name: "index_encryptables_on_tag"
  end

  create_table "folders", force: :cascade do |t|
    t.string "name", limit: 40, default: "", null: false
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "team_id", default: 0, null: false
    t.index ["name"], name: "index_folders_on_name"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", limit: 40, default: "", null: false
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: true, null: false
    t.boolean "private", default: false, null: false
    t.string "type", default: "Team::Shared", null: false
    t.integer "personal_owner_id"
    t.integer "recrypt_state", default: 1, null: false
    t.string "encryption_algorithm", default: "AES256", null: false
    t.index ["name"], name: "index_teams_on_name"
  end

  create_table "user_favourite_teams", force: :cascade do |t|
    t.integer "team_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.text "public_key", null: false
    t.binary "private_key", null: false
    t.binary "password"
    t.string "provider_uid"
    t.datetime "last_login_at", precision: nil
    t.string "username"
    t.string "givenname"
    t.string "surname"
    t.string "auth", default: "db", null: false
    t.string "preferred_locale", default: "en", null: false
    t.boolean "locked", default: false
    t.datetime "last_failed_login_attempt_at", precision: nil
    t.integer "failed_login_attempts", default: 0, null: false
    t.string "last_login_from"
    t.string "type"
    t.integer "human_user_id"
    t.text "options"
    t.integer "role", default: 0, null: false
    t.integer "default_ccli_user_id"
    t.index ["default_ccli_user_id"], name: "index_users_on_default_ccli_user_id"
  end

end
