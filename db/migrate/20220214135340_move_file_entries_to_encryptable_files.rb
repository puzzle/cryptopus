# frozen_string_literal: true

class MoveFileEntriesToEncryptableFiles < ActiveRecord::Migration[6.1]
  def up
    add_column :encryptables, :credential_id, :integer
    add_column :encryptables, :content_type, :text
    change_column :encryptables, :folder_id, :integer, null: true, default: nil
    change_column :encryptables, :name, :string, limit: 255

    Encryptable.reset_column_information

    LegacyFileEntry.find_each do |file_entry|
      encryptable_file = build_encryptable_entry(file_entry.account_id, file_entry.description, file_entry.filename)

      encryptable_file.encrypted_data.[]=(:file, **{ data: file_entry.file, iv: nil })
      encryptable_file.content_type = file_entry.content_type
      encryptable_file.save!
    end

    drop_table :file_entries
  end

  def down
    create_table :file_entries do |t|
      t.integer "account_id", default: 0, null: false
      t.text "description"
      t.binary "file"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "filename", null: false
      t.text "content_type", null: false
    end

    Encryptable::File.find_each do |file|
      parent_encryptable = file.encryptable_credential

      filename_prefix = parent_encryptable.name + ' '
      filename = file.name.sub(filename_prefix, '')
      data = nil
      data = file.encrypted_data[:file][:data] unless file.encrypted_data[:file].nil?

      file_entry = build_legacy_file_entry(parent_encryptable.id, data, filename, file.description, file.content_type)
      file_entry.save!
    end

    remove_column :encryptables, :credential_id
    remove_column :encryptables, :content_type
  end

  private

  def empty_encryptable?(encryptable)
    encryptable.encrypted_data.to_json == '{}'
  end

  def build_encryptable_entry(parent_id, description, name)
    Encryptable::File.new(credential_id: parent_id,
                          cleartext_file: 'dummy', # set this to skip validation
                          description: description,
                          name: name)
  end

  def build_legacy_file_entry(account_id, file, filename, description, content_type)
    LegacyFileEntry.new(account_id: account_id,
                        file: file,
                        filename: filename,
                        description: description,
                        content_type: content_type)
  end

  class LegacyFileEntry < ApplicationRecord
    self.table_name = 'file_entries'
  end
end
