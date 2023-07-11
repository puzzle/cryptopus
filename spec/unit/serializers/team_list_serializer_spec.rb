# frozen_string_literal: true

require 'spec_helper'

describe TeamListSerializer do
  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }


  context 'Transferred count' do

    it 'returns 0 if no transferred files in inbox folder' do
      as_json = JSON.parse(TeamListSerializer.new(teams(:personal_team_alice)).to_json)

      expect(as_json['unread_count']).to eq(0)
    end

    it 'returns 1 if unread transferred file present in inbox folder' do
      encryptable_file = Encryptable::File.new(name: 'file',
                                               folder_id: alice.inbox_folder.id,
                                               cleartext_file: file_fixture('test_file.txt').read,
                                               content_type: 'text/plain')

      transfer_password = Crypto::Symmetric::Aes256iv.random_key

      encryptable_file.encrypt(transfer_password)

      encrypted_transfer_password = Crypto::Rsa.encrypt(
        transfer_password,
        alice.public_key
      )
      encryptable_file.encrypted_transfer_password = Base64.encode64(encrypted_transfer_password)
      encryptable_file.sender_id = bob.id
      encryptable_file.folder = alice.inbox_folder
      encryptable_file.save!

      as_json = JSON.parse(TeamListSerializer.new(teams(:personal_team_alice)).to_json)

      expect(as_json['unread_count']).to eq(1)
    end

    it 'does not return count for non personal team' do
      as_json = JSON.parse(TeamListSerializer.new(teams(:team2)).to_json)

      expect(as_json['unread_count']).to eq(nil)
    end
  end
end
