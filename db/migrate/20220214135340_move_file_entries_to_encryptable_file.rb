# frozen_string_literal: true

class MoveFileEntriesToEncryptableFiles < ActiveRecord::Migration[6.1]
  def up
    add_column :encryptables, :credential_id, :integer
    add_column :encryptables, :content_type, :text

    Encryptable.reset_column_information

    LegacyFileEntry.find_each do |file_entry|
      parent_encryptable = Encryptable::Credentials.find(file_entry.account_id)
      filename = build_encryptable_file_name(parent_encryptable, file_entry)

      encryptable_file = build_encryptable_entry(parent_encryptable, file_entry.description, filename)

      encryptable_file.encrypted_data[:file] = { iv: nil, data: file_entry.file }
      encryptable_file.content_type = file_entry.content_type
      encryptable_file.save!

      if empty_encryptable?(parent_encryptable)
        parent_encryptable.destroy
      end
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

  def build_encryptable_file_name(encryptable, file)
    "#{encryptable.name} #{file.filename}"
  end

  def build_encryptable_entry(parent_encryptable, description, name)
    Encryptable::File.new(folder_id: parent_encryptable.folder_id,
                          credential_id: parent_encryptable.id,
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
