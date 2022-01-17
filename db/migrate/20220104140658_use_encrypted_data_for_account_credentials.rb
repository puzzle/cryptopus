# frozen_string_literal: true

class UseEncryptedDataForAccountCredentials < ActiveRecord::Migration[6.1]

  MEDIUM_TEXT_LIMIT = (16.megabytes - 1)

  def up
    change_column :accounts, :encrypted_data, :text, limit: MEDIUM_TEXT_LIMIT
    rename_column :accounts, :accountname, :name

    LegacyAccountCredentials.reset_column_information

    LegacyAccountCredentials.find_each do |a|
      # some blob values were set to "" that's why we're using .presence here
      a.encrypted_data[:password] = { iv: nil, data: a.password.presence }
      a.encrypted_data[:username] = { iv: nil, data: a.username.presence }
      a.save!
    end

    remove_column :accounts, :password
    remove_column :accounts, :username
  end

  def down
    add_column :accounts, :password, :binary
    add_column :accounts, :username, :binary

    LegacyAccountCredentials.reset_column_information

    LegacyAccountCredentials.find_each do |a|
      a.password = a.encrypted_data[:password].try(:[], :data)
      a.username = a.encrypted_data[:username].try(:[], :data)
      a.encrypted_data = nil
      a.save!
    end

    rename_column :accounts, :name, :accountname
    change_column :accounts, :encrypted_data, :text
  end

  private

  class LegacyAccountCredentials < ApplicationRecord
    self.table_name = 'accounts'
    self.inheritance_column = nil

    serialize :encrypted_data, ::EncryptedData
  end

end
