class FixAutoUidBug < ActiveRecord::Migration
  def self.up
    # We cannot use the id as the uid, because this is autoincrement
    # Create the User table new tu ensure that autoincrement is on
    user_table = Hash.new
    User.all.each do |user|
      user_table[user.id] = Hash.new
      user_table[user.id][:public_key]  = user.public_key
      user_table[user.id][:private_key] = user.private_key
      user_table[user.id][:password]    = user.password
      user_table[user.id][:admin]       = user.admin
    end

    drop_table "users"
    create_table "users", :force => true do |t|
      t.column "public_key",  :text,                       :null => false
      t.column "private_key", :binary,                     :null => false
      t.column "password",    :binary
      t.column "admin",       :boolean, :default => false, :null => false
      t.column "uid",         :integer,                    :null => false
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

    Recryptrequest.all.each do |recryptrequest|
      user = User.where("uid = ?", recryptrequest.user_id).first
      recryptrequest.user_id = user.id
      recryptrequest.save
    end

    Teammember.all.each do |teammember|
      user = User.where("uid = ?", teammember.user_id).first
      teammember.user_id = user.id
      teammember.save
    end

  end

  def self.down
    Teammember.all.each do |teammember|
      user = User.find(teammember.user_id)
      teammember.user_id = user.uid
      teammember.save
    end

    Recryptrequest.all.each do |recryptrequest|
      user = User.find(recryptrequest.user_id)
      recryptrequest.user_id = user.uid
      recryptrequest.save
    end

    remove_column "users", "id"
    rename_column "users", "uid", "id"
  end
end
