# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FixAutoUidBug < ActiveRecord::Migration[4.2]
  def up
    # We cannot use the id as the uid, because this is autoincrement
    # Create the User table new tu ensure that autoincrement is on
    user_table = Hash.new
    User.unscoped.find_each do |user|
      user_table[user.id] = Hash.new
      user_table[user.id][:public_key]  = user.public_key
      user_table[user.id][:private_key] = user.private_key
      user_table[user.id][:password]    = user.password
      user_table[user.id][:admin]       = user.admin
    end

    drop_table :users
    create_table :users, force: true do |t|
      t.text :public_key, null: false
      t.binary :private_key, null: false
      t.binary :password
      t.boolean :admin, default: false, null: false
      t.integer :uid, null: false
    end
    User.reset_column_information

    user_table.each do |uid, data|
      new_user = User.new
      new_user.uid         = uid
      new_user.public_key  = data[:public_key]
      new_user.private_key = data[:private_key]
      new_user.password    = data[:password]
      new_user.admin       = data[:admin]
      new_user.save
    end

    Recryptrequest.find_each do |recryptrequest|
      user = User.where("uid = ?", recryptrequest.user_id).first
      recryptrequest.user_id = user.id
      recryptrequest.save
    end

    Teammember.find_each do |teammember|
      user = User.where("uid = ?", teammember.user_id).first
      teammember.user_id = user.id
      teammember.save
    end

  end

  def down
    Teammember.find_each do |teammember|
      user = User.find(teammember.user_id)
      teammember.user_id = user.uid
      teammember.save
    end

    Recryptrequest.find_each do |recryptrequest|
      user = User.find(recryptrequest.user_id)
      recryptrequest.user_id = user.uid
      recryptrequest.save
    end

    remove_column :users, :id
    rename_column :users, :uid, :id
  end
end
