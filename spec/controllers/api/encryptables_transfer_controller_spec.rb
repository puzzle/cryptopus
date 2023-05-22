# frozen_string_literal: true

require 'spec_helper'

describe Api::EncryptablesTransferController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:credentials2) { encryptables(:credentials2) }


  context 'Encryptable File Transfer' do

    it 'does not send encryptable file to api user' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_params = {
        content_type: 'text/plain',
        file: file,
        description: 'test',
        receiver_id: api_user.id
      }

      post :create, params: file_params, xhr: true
      expect(response).to have_http_status(404)

    end

    it 'does not send encryptable file to non existing user' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')

      file_params = {
        content_type: 'text/plain',
        file: file,
        description: 'test',
        receiver_id: nil
      }

      post :create, params: file_params, xhr: true
      expect(response).to have_http_status(404)

    end

    it 'Bob sends file to alice' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_params = {
        content_type: 'text/plain',
        file: file,
        description: 'test',
        receiver_id: alice.id
      }

      post :create, params: file_params, xhr: true

      expect(response).to have_http_status(200)

      transferred_encryptable = alice.personal_team.folders.last.encryptables.last
      plaintext_team_password =
        alice.personal_team.decrypt_team_password(alice, alice.decrypt_private_key('password'))

      EncryptableTransfer.new.receive(transferred_encryptable,
                                      alice.decrypt_private_key('password'),
                                      plaintext_team_password)

      expect(transferred_encryptable.name).to eq('test_file.txt')
      expect(transferred_encryptable.description).to eq('test')
      expect(transferred_encryptable.sender_id).to eq(bob.id)
      expect(transferred_encryptable.cleartext_file).to eq('certificate')
    end
  end

  context 'Encryptable Credentials Transfer' do

    it 'does not send encryptable credentials to non allowed user' do
      login_as(:alice)

      request_params = {
        receiver_id: 139081,
        encryptable_id: credentials2.id
      }

      expect do
        post :create, params: request_params, xhr: true
      end.to raise_error('You have no access to this team')

    end

    it 'Bob sends credentials to Alice' do
      login_as(:bob)

      request_params = {
        receiver_id: alice.id,
        encryptable_id: credentials2.id
      }

      post :create, params: request_params, xhr: true

      expect(response).to have_http_status(200)

      transferred_encryptable = alice.personal_team.folders.last.encryptables.last
      plaintext_team_password =
        alice.personal_team.decrypt_team_password(alice, alice.decrypt_private_key('password'))

      EncryptableTransfer.new.receive(transferred_encryptable,
                                      alice.decrypt_private_key('password'),
                                      plaintext_team_password)

      expect(transferred_encryptable.name).to eq('Twitter Account')
      expect(transferred_encryptable.id).not_to eq(credentials2.id)
      expect(transferred_encryptable.description).to eq('My personal twitter account')
      expect(transferred_encryptable.sender_id).to eq(bob.id)
      expect(transferred_encryptable.encrypted_transfer_password).to eq(nil)
    end
  end

end
