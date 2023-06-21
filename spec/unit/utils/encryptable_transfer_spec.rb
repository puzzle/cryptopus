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

      received_file = bob.inbox_folder.encryptables.first

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

    it 'Transfers encryptable credentials to other user' do
      receiver = bob
      sender = alice

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.first

      expect(received_encryptable.encrypted_transfer_password).to be_present

      encryptable_transfer.transfer(encryptable_credentials1, receiver, sender)

      received_encryptable = bob.inbox_folder.encryptables.last

      expect(received_encryptable.encrypted_transfer_password).to be_present
      expect(received_encryptable.name).to eq('Personal Mailbox(1)')
      expect(received_encryptable.sender_id).to eq(alice.id)
      expect(received_encryptable.description).to eq(encryptable_credentials1.description)
    end
  end

  context '#receive' do
    it 'Recrypts encryptable file when received' do
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
  end

  context '#encryptable_destination_name' do
    let(:receiver) do
      receiver = bob
      allow(receiver).
        to receive_message_chain(:inbox_folder,
                                 :encryptables,
                                 :pluck).and_return(@existing_names)
      receiver
    end

    context 'For File' do
      it 'Keeps "invoice.pdf" if same name does not exist' do
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = []

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice.pdf')
      end

      it 'Becomes "invoice(1).pdf" if "invoice.pdf" exists' do
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = ['invoice.pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice(1).pdf')
      end

      it 'Becomes "invoice(2).pdf" if "invoice.pdf" and "invoice(1).pdf" exists' do
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = ['invoice.pdf', 'invoice(1).pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice(2).pdf')
      end

      it 'Becomes "invoice(3).pdf" if "invoice.pdf", "invoice(1).pdf" and "invoice(2).pdf" exists' do # rubocop:disable Layout/LineLength
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = ['invoice(2).pdf', 'invoice.pdf', 'invoice(1).pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice(3).pdf')
      end

      it 'Increase "invoice(1).pdf" to "invoice(2).pdf" if "invoice.pdf" and "invoice(1).pdf" exists' do # rubocop:disable Layout/LineLength
        encryptable = Encryptable::File.new(name: 'invoice(1).pdf')
        @existing_names = ['invoice(1).pdf', 'invoice.pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice(2).pdf')
      end

      it 'Keeps "invoice.pdf" if "invoice(1).pdf" but no "invoice.pdf" exists' do
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = ['invoice(1).pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice.pdf')
      end

      it 'Keeps "invoice.pdf" if "blabliblu invoice.pdf" exist' do
        encryptable = Encryptable::File.new(name: 'invoice.pdf')
        @existing_names = ['blabliblu invoice.pdf']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('invoice.pdf')
      end
    end

    context 'For credential' do

      it 'Keeps "Mailbox" if same name does not exist' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names = []

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox')
      end

      it 'Becomes "Mailbox(1)" if "Mailbox" exists' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names = ['Mailbox']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox(1)')
      end

      it 'Becomes "Mailbox(2)" if "Mailbox" and "Mailbox(1)" exists' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names = ['Mailbox 42', 'Mailbox(1)', 'Mailbox']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox(2)')
      end

      it 'Becomes "Mailbox(3)" if "Mailbox", "Mailbox(1)" and "Mailbox(2)" exists' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names =
          ['Mailbox', 'another.pdf', 'Mailbox(1)', 'Mailbox other.pdf', 'Mailbox(2)']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox(3)')
      end

      it 'Increase "Mailbox(1)" to "Mailbox(2)" if "Mailbox(1)" exist' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox(1)')
        @existing_names = ['Mailbox(1)', 'Mailbox']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox(2)')
      end

      it 'Keeps "Mailbox" if "Mailbox(1)" but no "Mailbox" exists' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names = ['Mailbox(1)']

        destination_name = encryptable_transfer.send(:encryptable_destination_name, encryptable,
                                                     receiver)

        expect(destination_name).to eq('Mailbox')
      end

      it 'Keeps "Mailbox" if "Mailbox BOB" exist' do
        encryptable = Encryptable::Credentials.new(name: 'Mailbox')
        @existing_names = ['Mailbox BOB']

        destination_name = encryptable_transfer.send(
          :encryptable_destination_name,
          encryptable,
          receiver
        )

        expect(destination_name).to eq('Mailbox')
      end
    end
  end

end
