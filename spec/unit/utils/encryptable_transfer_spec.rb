# frozen_string_literal: true

require 'spec_helper'

describe EncryptableTransfer do

  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }
  let(:api_tux) { users(:api_tux) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:team1) { teams(:team1) }

  let(:encryptable_transfer) { described_class.new }
  let(:encryptable_credentials1) { encryptables(:credentials1) }
  let(:encryptable_credentials2) { encryptables(:credentials2) }
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

      encryptable_transfer.receive(received_file, bobs_private_key, personal_team_password)

      expect(received_file.transferred?).to eq(false)
      expect(received_file.encrypted_transfer_password).to be_nil
      expect(received_file.sender_id).to eq(alice.id)
      expect(received_file.cleartext_file).to eq(encryptable_file.cleartext_file)
      expect(received_file.name).to eq(encryptable_file.name)
      expect(received_file.content_type).to eq('text/plain')
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

      expect(received_file.sender_id).to eq(bob.id)
      expect(received_file.encrypted_transfer_password).to be_nil
    end

    it 'Adds (1) to the encryptable name if this name is already taken in inbox folder' do
      receiver = bob
      sender = alice

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.first

      expect(received_encryptable.encrypted_transfer_password).to be_present

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.last

      expect(received_encryptable.encrypted_transfer_password).to be_present
      expect(received_encryptable.name).to eq('Personal Mailbox (1)')
    end

    it 'Adds (2) to the encryptable name if name (1) already is taken in inbox folder' do
      receiver = bob
      sender = alice

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)
      expect(receiver.inbox_folder.encryptables.count).to eq 1

      encryptable_credentials1.name += ' (1)'

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.first

      expect(received_encryptable.encrypted_transfer_password).to be_present
      expect(received_encryptable.name).to eq(encryptable_credentials1.name)

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.last

      expect(received_encryptable.name).to eq('Personal Mailbox (2)')
    end

    it 'Does not add (1) when name is not exact' do
      receiver = bob
      sender = alice

      encryptable_credentials1.name = 'Personal Mailbox text'

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.first

      expect(received_encryptable.name).to eq(encryptable_credentials1.name)

      encryptable_credentials1.name = 'Personal Mailbox'

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.last

      expect(received_encryptable.name).to eq('Personal Mailbox')
    end
  end
end
