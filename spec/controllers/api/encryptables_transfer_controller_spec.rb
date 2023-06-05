# frozen_string_literal: true

require 'spec_helper'

describe Api::EncryptablesTransferController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:credentials2) { encryptables(:credentials2) }


  context 'Encryptable File Transfer' do
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

    it 'Does not send encryptable file to an api user' do
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

    it 'Does not send encryptable file to non existing user' do
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

    it 'Alice transfers image file to Bob' do
      login_as(:alice)

      file = fixture_file_upload('smallImage.png', 'image/png')
      image_md5 = 'da18d72ee09ca9a6043a0b93712bf7a8'
      file_params = {
        content_type: 'image/png',
        file: file,
        description: 'Draft for background color',
        receiver_id: bob.id
      }

      post :create, params: file_params, xhr: true

      expect(response).to have_http_status(200)
      expect(response.body).to include('flashes.encryptable_transfer.file.transferred')

      transferred_encryptable = bob.inbox_folder.encryptables.last
      plaintext_team_password =
        bob.personal_team.decrypt_team_password(bob, bob.decrypt_private_key('password'))

      EncryptableTransfer.new.receive(transferred_encryptable,
                                      bob.decrypt_private_key('password'),
                                      plaintext_team_password)

      expect(transferred_encryptable.name).to eq('smallImage.png')
      expect(transferred_encryptable.description).to eq('Draft for background color')
      expect(transferred_encryptable.sender_id).to eq(alice.id)
      cleartext_file = transferred_encryptable.cleartext_file
      expect(Digest::MD5.hexdigest(cleartext_file)).to eq(image_md5)
    end

    it 'Alice transfers ascii encoded file to Bob' do
      login_as(:alice)

      file = fixture_file_upload('ascii-text-windows.txt', 'text/plain')
      file_md5 = 'bf7d309a5c388f67d7cab60aaef681ce'
      file_params = {
        content_type: 'text/plain',
        file: file,
        description: 'an ascii encoded file',
        receiver_id: bob.id
      }

      post :create, params: file_params, xhr: true

      expect(response).to have_http_status(200)
      expect(response.body).to include('flashes.encryptable_transfer.file.transferred')

      transferred_encryptable = bob.inbox_folder.encryptables.last
      plaintext_team_password =
        bob.personal_team.decrypt_team_password(bob, bob.decrypt_private_key('password'))

      EncryptableTransfer.new.receive(transferred_encryptable,
                                      bob.decrypt_private_key('password'),
                                      plaintext_team_password)

      expect(transferred_encryptable.name).to eq('ascii-text-windows.txt')
      expect(transferred_encryptable.description).to eq('an ascii encoded file')
      expect(transferred_encryptable.sender_id).to eq(alice.id)
      cleartext_file = transferred_encryptable.cleartext_file
      expect(Digest::MD5.hexdigest(cleartext_file)).to eq(file_md5)
    end
  end

  context 'Encryptable Credentials Transfer' do
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

  it 'Does not send encryptable credentials to non existing user' do
    login_as(:bob)

    request_params = {
      receiver_id: 139082421,
      encryptable_id: credentials2.id
    }

    post :create, params: request_params, xhr: true

    expect(response.body).to include('flashes.api.errors.record_not_found')
    expect(response).to have_http_status(404)
  end

  it 'Does not send encryptable credentials which the sender does not have access to' do
    login_as(:alice)
    api_controller = ApiController.new

    request_params = {
      receiver_id: bob.id,
      encryptable_id: credentials2.id
    }

    expect(api_controller).not_to receive(:decrypted_team_password)


    post :create, params: request_params, xhr: true

    expect(response.body).to include('flashes.api.errors.record_not_found')
    expect(response).to have_http_status(404)
  end

end
