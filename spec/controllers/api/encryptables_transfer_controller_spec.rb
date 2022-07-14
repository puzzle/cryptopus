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

      expect(response).to have_http_status(201)

      id = JSON.parse(response.body).dig('data', 'id')
      shared_file = Encryptable.find(id)

      expect(shared_file.sender_id).to eq(bob.id)
      expect(shared_file.encrypted_transfer_password).present?

      login_as(:alice)

      get :show, params: { id: shared_file.id }, xhr: true

      expect(response).to have_http_status(200)

      received_file = Encryptable.find(shared_file.id)
      file_content = fixture_file_upload('test_file.txt', 'text/plain').read

      expect(received_file.encrypted_transfer_password).to eq(nil)
      expect(received_file.sender_id).to eq(bob.id)
      expect(received_file.name).to eq('test_file.txt')
      expect(received_file.description).to eq('test')
      expect(received_file.content_type).to eq('text/plain')
      expect(received_file.folder_id).to eq(alice.inbox_folder.id)
      expect(response.body).to eq file_content
    end
  end

end