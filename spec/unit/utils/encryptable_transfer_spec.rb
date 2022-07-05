# frozen_string_literal: true

require 'spec_helper'

describe EncryptableTransfer do

  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:team1) { teams(:team1) }

  let(:encryptable_transfer) { described_class.new }

  let(:encryptable_file) do
    Encryptable::File.new(cleartext_file: 'fff', name: 'info.txt', content_type: 'text/plain')
  end

  context '#transfer' do
    it 'transfers encryptable file to other user' do
      receiver = bob
      sender = alice

      encryptable_transfer.transfer(encryptable_file, receiver, sender)

      received_file = bob.personal_team.folders.find_by(name: 'inbox').encryptables.first
      expect(received_file.encrypted_transfer_password).to be_present

      personal_team_password = bob.personal_team.decrypt_team_password(bob, bobs_private_key)

      received_file.recrypt_transferred(bobs_private_key, personal_team_password)

      expect(received_file.encrypted_transfer_password).to be_nil
      expect(received_file.cleartext_file).to eq(encryptable_file.cleartext_file)
      expect(received_file.name).to eq(encryptable_file.name)
      expect(received_file.content_type).to eq('text/plain')
      expect(received_file.sender_id).to eq(alice.id)
    end

    it 'recrypts encryptable when received' do
      transfered_encryptable = encryptable_transfer.transfer(encryptable_file, alice, bob)

      personal_team = alice.personal_team
      private_key = alice.decrypt_private_key('password')

      personal_team_password = personal_team.decrypt_team_password(alice, private_key)
      received_file = encryptable_transfer.receive(transfered_encryptable, private_key,
                                                   personal_team_password)

      expect(received_file.cleartext_file).to eq(encryptable_file.cleartext_file)
      expect(received_file.name).to eq(encryptable_file.name)
      expect(received_file.content_type).to eq('text/plain')

      expect(received_file.encrypted_transfer_password).to be_nil
      expect(received_file.receiver_id).to be_nil
    end
  end
end
