# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class CreateInitialSchema < ActiveRecord::Migration[5.1]

  def change
    create_table :accounts, force: true do |t|
      t.string :accountname, limit: 40, default: "", null: false
      t.integer :group_id, default: 0,  null: false
      t.text :description
      t.binary :username
      t.binary :password
      t.timestamps
    end

    create_table :grouppasswords, force: true do |t|
      t.integer :group_id, default: 0,  null: false
      t.binary :password, null: false
      t.integer :user_id, default: 0,  null: false
      t.timestamps
    end

    create_table :groups, force: true do |t|
      t.string :groupname, limit: 40, default: "", null: false
      t.text :description
      t.timestamps
      t.integer :user_id, default: 0,  null: false
    end

    create_table :items, force: true do |t|
      t.integer :account_id, default: 0,  null: false
      t.text :description
      t.binary :file
      t.timestamps
      t.text :filename, null: false
      t.text :content_type, null: false
    end

    create_table :ldapsettings, force: true do |t|
      t.string :basename, limit: 200, default: "ou=users,dc=yourdomain,dc=com", null: false
      t.string :hostname, limit: 50,  default: "yourdomain.com", null: false
      t.string :portnumber, limit: 10,  default: "636", null: false
      t.string :encryption, limit: 30,  default: "simple_tls", null: false
    end

    create_table :recryptrequests, force: true do |t|
      t.integer :user_id, default: 0, null: false
    end

    create_table :users, force: true do |t|
      t.text :public_key, null: false
      t.binary :private_key, :binary, null: false
      t.binary :password
    end
  end
end
