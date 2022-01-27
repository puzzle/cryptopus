class MoveFilesFromCredentialToFolder < ActiveRecord::Migration[6.1]
  def up
    LegacyFileEntry.find_each do |file_entry|
      parent_encryptable = Encryptable.find(file_entry.account_id)

      encryptable_file = Encryptable::File.new(
        folder_id: parent_encryptable.folder_id,
        description: file_entry.description,
        name: build_encryptable_file_name(parent_encryptable, file_entry)
      )

      encryptable_file.encrypted_data[:file] = { iv: nil, data: file_entry.file }
      encryptable_file.save

      if empty_encryptable?(parent_encryptable)
        parent_encryptable.destroy
      end
    end
  end

  private

  def empty_encryptable?(encryptable)
    encryptable.encrypted_data.to_json == '{}'
  end

  def build_encryptable_file_name(encryptable, file)
    "#{encryptable.name} #{file.filename}"
  end

  class LegacyFileEntry < ApplicationRecord
    self.table_name = 'file_entries'
  end
end
