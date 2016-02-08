# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    
  create_table "accounts", :force => true do |t|
    t.column "accountname", :string,    :limit => 40, :default => "", :null => false
    t.column "group_id",    :integer,                 :default => 0,  :null => false
    t.column "description", :text
    t.column "username",    :binary
    t.column "password",    :binary
    t.column "created_on",  :timestamp,                               :null => false
    t.column "updated_on",  :timestamp,                               :null => false
  end

  create_table "grouppasswords", :force => true do |t|
    t.column "group_id",   :integer,   :default => 0,  :null => false
    t.column "password",   :binary,    :null => false
    t.column "user_id",    :integer,   :default => 0,  :null => false
    t.column "created_on", :timestamp,                 :null => false
    t.column "updated_on", :timestamp,                 :null => false
  end

  create_table "groups", :force => true do |t|
    t.column "groupname",   :string,    :limit => 40, :default => "", :null => false
    t.column "description", :text
    t.column "created_on",  :timestamp,                               :null => false
    t.column "updated_on",  :timestamp,                               :null => false
    t.column "user_id",     :integer,                 :default => 0,  :null => false
  end

  create_table "items", :force => true do |t|
    t.column "account_id",   :integer,   :default => 0,  :null => false
    t.column "description",  :text
    t.column "file",         :binary
    t.column "created_on",   :timestamp,                 :null => false
    t.column "updated_on",   :timestamp,                 :null => false
    t.column "filename",     :text,      :null => false
    t.column "content_type", :text,      :null => false
  end

  create_table "ldapsettings", :force => true do |t|
    t.column "basename",   :string, :limit => 200, :default => "ou=users,dc=yourdomain,dc=com", :null => false
    t.column "hostname",   :string, :limit => 50,  :default => "yourdomain.com",                :null => false
    t.column "portnumber", :string, :limit => 10,  :default => "636",                           :null => false
    t.column "encryption", :string, :limit => 30,  :default => "simple_tls",                    :null => false
  end

  create_table "recryptrequests", :force => true do |t|
    t.column "user_id", :integer, :default => 0, :null => false
  end

  create_table "users", :force => true do |t|
    t.column "public_key",  :text,   :null => false
    t.column "private_key", :binary, :null => false
    t.column "password",    :binary
  end
  end

  def self.down
    drop_table :accounts
    drop_table :grouppasswords
    drop_table :groups
    drop_table :items
    drop_table :ldapsettings
    drop_table :recryptrequests
    drop_table :users
  end
end
