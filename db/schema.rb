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

ActiveRecord::Schema.define(version: 20151119133600) do

  create_table "accounts", force: :cascade do |t|
    t.string   "accountname", limit: 40,    default: "", null: false
    t.integer  "group_id",    limit: 4,     default: 0,  null: false
    t.text     "description", limit: 65535
    t.binary   "username",    limit: 65535
    t.binary   "password",    limit: 65535
    t.datetime "created_on",                             null: false
    t.datetime "updated_on",                             null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 40,    default: "", null: false
    t.text     "description", limit: 65535
    t.datetime "created_on",                             null: false
    t.datetime "updated_on",                             null: false
    t.integer  "team_id",     limit: 4,     default: 0,  null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "account_id",   limit: 4,     default: 0, null: false
    t.text     "description",  limit: 65535
    t.binary   "file",         limit: 65535
    t.datetime "created_on",                             null: false
    t.datetime "updated_on",                             null: false
    t.text     "filename",     limit: 65535,             null: false
    t.text     "content_type", limit: 65535,             null: false
  end

  create_table "recryptrequests", force: :cascade do |t|
    t.integer "user_id",       limit: 4, default: 0,    null: false
    t.boolean "adminrequired", limit: 1, default: true, null: false
    t.boolean "rootrequired",  limit: 1, default: true, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "key",   limit: 255, null: false
    t.string "value", limit: 255
    t.string "type",  limit: 255, null: false
  end

  create_table "teammembers", force: :cascade do |t|
    t.integer  "team_id",    limit: 4,     default: 0,     null: false
    t.binary   "password",   limit: 65535,                 null: false
    t.integer  "user_id",    limit: 4,     default: 0,     null: false
    t.datetime "created_on",                               null: false
    t.datetime "updated_on",                               null: false
    t.boolean  "admin",      limit: 1,     default: false, null: false
    t.boolean  "locked",     limit: 1,     default: false, null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",        limit: 40,    default: "",    null: false
    t.text     "description", limit: 65535
    t.datetime "created_on",                                null: false
    t.datetime "updated_on",                                null: false
    t.boolean  "visible",     limit: 1,     default: true,  null: false
    t.boolean  "private",     limit: 1,     default: false, null: false
    t.boolean  "noroot",      limit: 1,     default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.text     "public_key",                   limit: 65535,                 null: false
    t.binary   "private_key",                  limit: 65535,                 null: false
    t.binary   "password",                     limit: 65535
    t.boolean  "admin",                        limit: 1,     default: false, null: false
    t.integer  "uid",                          limit: 4
    t.datetime "last_login_at"
    t.string   "username",                     limit: 255
    t.string   "givenname",                    limit: 255
    t.string   "surname",                      limit: 255
    t.string   "auth",                         limit: 255,   default: "db",  null: false
    t.string   "preferred_locale",             limit: 255,   default: "en",  null: false
    t.boolean  "locked",                       limit: 1,     default: false
    t.datetime "last_failed_login_attempt_at"
    t.integer  "failed_login_attempts",        limit: 4,     default: 0,     null: false
  end

end
