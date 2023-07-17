# frozen_string_literal: true

require 'spec_helper'

describe FolderSerializer do
  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }


  context 'No files transferred' do

    it 'should return 0 unread transferred files' do
      as_json = JSON.parse(FolderSerializer.new(folders(:inbox_folder_alice)).to_json)

      expect(as_json['unread_transferred_count']).to eq(0)
    end
  end

  context 'Some files transferred' do

    it 'should return 1 unread transferred file' do
      encryptable_file = Encryptable::File.new(name: 'file',
                                               folder_id: alice.inbox_folder.id,
                                               cleartext_file: file_fixture('test_file.txt').read,
                                               content_type: 'text/plain')

      transfer_password = Crypto::Symmetric::Aes256.random_key

      encryptable_file.encrypt(transfer_password)

      encrypted_transfer_password = Crypto::Rsa.encrypt(
        transfer_password,
        alice.public_key
      )
      encryptable_file.encrypted_transfer_password = Base64.encode64(encrypted_transfer_password)
      encryptable_file.sender_id = bob.id
      encryptable_file.folder = alice.inbox_folder
      encryptable_file.save!

      as_json = JSON.parse(FolderSerializer.new(folders(:inbox_folder_alice)).to_json)

      expect(as_json['unread_transferred_count']).to eq(1)
    end
  end
end
