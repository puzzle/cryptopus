# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "accounts", :force => true do |t|
    t.string   "accountname", :limit => 40, :default => "", :null => false
    t.integer  "group_id",                  :default => 0,  :null => false
    t.text     "description"
    t.binary   "username"
    t.binary   "password"
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name",        :limit => 40, :default => "", :null => false
    t.text     "description"
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
    t.integer  "team_id",                   :default => 0,  :null => false
  end

  create_table "items", :force => true do |t|
    t.integer  "account_id",   :default => 0, :null => false
    t.text     "description"
    t.binary   "file"
    t.datetime "created_on",                  :null => false
    t.datetime "updated_on",                  :null => false
    t.text     "filename",                    :null => false
    t.text     "content_type",                :null => false
  end

  create_table "ldapsettings", :force => true do |t|
    t.string "basename",      :limit => 200, :default => "ou=users,dc=yourdomain,dc=com", :null => false
    t.string "hostname",      :limit => 50,  :default => "yourdomain.com",                :null => false
    t.string "portnumber",    :limit => 10,  :default => "636",                           :null => false
    t.string "encryption",    :limit => 30,  :default => "simple_tls",                    :null => false
    t.string "bind_dn"
    t.string "bind_password"
  end

  create_table "recryptrequests", :force => true do |t|
    t.integer "user_id",       :default => 0,    :null => false
    t.boolean "adminrequired", :default => true, :null => false
    t.boolean "rootrequired",  :default => true, :null => false
  end

  create_table "teammembers", :force => true do |t|
    t.integer  "team_id",    :default => 0,     :null => false
    t.binary   "password",                      :null => false
    t.integer  "user_id",    :default => 0,     :null => false
    t.datetime "created_on",                    :null => false
    t.datetime "updated_on",                    :null => false
    t.boolean  "team_admin", :default => false, :null => false
    t.boolean  "admin",      :default => false, :null => false
    t.boolean  "locked",     :default => false, :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name",        :limit => 40, :default => "",    :null => false
    t.text     "description"
    t.datetime "created_on",                                   :null => false
    t.datetime "updated_on",                                   :null => false
    t.boolean  "visible",                   :default => true,  :null => false
    t.boolean  "private",                   :default => false, :null => false
    t.boolean  "noroot",                    :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.text    "public_key",                     :null => false
    t.binary  "private_key",                    :null => false
    t.binary  "password"
    t.boolean "admin",       :default => false, :null => false
    t.integer "uid",                            :null => false
  end

end
