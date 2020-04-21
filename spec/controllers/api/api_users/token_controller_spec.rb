# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::TokenController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }
  let!(:foreign_api_user) { users(:alice).api_users.create! }
  let(:foreign_private_key) { users(:alice).decrypt_private_key('password') }

  context 'GET show' do
    it 'bob can renew his token' do
      old_token = api_user.send(:decrypt_token, private_key)

      get :show, params: { id: api_user.id }, xhr: true

      api_user.reload

      new_token = api_user.send(:decrypt_token, private_key)

      expect(api_user).to_not be_locked
      expect(api_user.authenticate(old_token)).to eq false
      expect(api_user.authenticate(new_token)).to eq true
    end

    it 'bob cannot renew token of alice' do

      old_hash = foreign_api_user.password

      get :show, params: { id: foreign_api_user.id }, xhr: true

      foreign_api_user.reload

      new_hash = foreign_api_user.password

      expect(response).to have_http_status(403)
      expect(new_hash).to eq old_hash

    end
  end

  context 'DELETE destroy' do
    it 'bob can invalidate his token' do
      delete :destroy, params: { id: api_user.id }

      api_user.reload

      token = api_user.send(:decrypt_token, private_key)

      expect(api_user).to be_locked
      expect(api_user.authenticate(token)).to eq false
    end

    it 'bob cannot invalidate token of alice' do

      delete :destroy, params: { id: foreign_api_user.id }

      expect(response).to have_http_status(403)

    end
  end
end
