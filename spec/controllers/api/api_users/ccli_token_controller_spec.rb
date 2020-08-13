# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::CcliTokenController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET show' do
    it 'user gets ccli token, base_url and renews token' do
      @token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username

      get :show, params: { id: api_user.id }, xhr: true

      api_user.reload

      expect(api_user).to_not be_locked
      decoded_token = Base64.decode64(json['ccli_token'])
      received_username = decoded_token.split(';').first
      received_token = decoded_token.split(';').second
      expect(received_username).to eq(@username)
      renewed_token = api_user.send(:decrypt_token, private_key)
      expect(received_token).to eq(renewed_token)
      expect(json['base_url']).to eq('http://test.host')
    end

    it 'user cannot renew token of foreign_api_user' do
      get :show, params: { id: foreign_api_user.id }, xhr: true

      expect(response).to have_http_status(403)
    end
  end
end
