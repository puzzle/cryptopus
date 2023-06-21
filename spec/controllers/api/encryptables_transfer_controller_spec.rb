# frozen_string_literal: true

require 'spec_helper'

describe Api::EncryptablesTransferController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }


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
  end

end
