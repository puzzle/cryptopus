# frozen_string_literal: true

require 'spec_helper'

describe EncryptableTransfer do

  let(:encryptable) { encryptables(:credentials1) }
  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }
  let(:api_tux) { users(:api_tux) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:team1) { teams(:team1) }

  let(:encryptable_transfer) { described_class.new }

  let(:encryptable_file) do
    Encryptable::File.new(cleartext_file: 'fff', name: 'info.txt', content_type: 'text/plain')
  end

  context '#transfer' do
    it 'transfers encryptable file to other user' do
      receiver = bob
      sender_id = alice.id

      encryptable_transfer.transfer(encryptable_file, receiver, sender_id)

      received_file = bob.personal_team.folders.find_by(name: 'inbox').encryptables.first

      expect(received_file.encrypted_transfer_password).to be_present

      personal_team_password = bob.personal_team.decrypt_team_password(bob, bobs_private_key)

      received_file.recrypt_transferred(bobs_private_key, personal_team_password)

      expect(received_file.encrypted_transfer_password).to be_nil
      expect(received_file.cleartext_file).to eq(encryptable_file.cleartext_file)
      expect(received_file.name).to eq(encryptable_file.name)
      expect(received_file.content_type).to eq("text/plain")
      expect(received_file.sender_id).to eq(alice.id)
    end

    it 'does not transfer encryptable file to non existent user' do
      receiver = nil
      sender_id = alice.id

      expect { encryptable_transfer.transfer(encryptable_file, receiver, sender_id) }.to raise_error(StandardError, "Receiver user not found")
    end

    it 'does not transfer encryptable file to api user' do
      receiver = api_tux
      sender_id = alice.id

      expect { encryptable_transfer.transfer(encryptable_file, receiver, sender_id) }.to raise_error(StandardError, "Cant transfer to API user")
    end

  end

  context '#receive' do
    it 'recrypts encryptable when received' do
      transfered_encryptable = encryptable_transfer.transfer(encryptable_file, alice, bob.id)

      personal_team = alice.personal_team
      private_key = alice.decrypt_private_key('password')

      personal_team_password = personal_team.decrypt_team_password(alice, private_key)
      received_file = encryptable_transfer.receive(transfered_encryptable, private_key, personal_team_password)

      expect(received_file.cleartext_file).to eq(encryptable_file.cleartext_file)
      expect(received_file.name).to eq(encryptable_file.name)
      expect(received_file.content_type).to eq("text/plain")

      expect(received_file.sender_id).to be_nil
      expect(received_file.encrypted_transfer_password).to be_nil
      expect(received_file.receiver_id).to be_nil
    end

    it 'does not recrypt credentials with transfer attributes' do
      transfered_encryptable = encryptable_transfer.transfer(encryptables(:credentials1), alice, bob.id)

      personal_team = alice.personal_team
      private_key = alice.decrypt_private_key('password')

      personal_team_password = personal_team.decrypt_team_password(alice, private_key)

      expect do
        encryptable_transfer.receive(transfered_encryptable, private_key, personal_team_password)
      end.to raise_error(RuntimeError, "implement in subclass")
    end
  end
end
