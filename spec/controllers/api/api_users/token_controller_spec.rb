# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::TokenController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }

  context 'GET show' do
    it 'user renews token' do
      old_token = api_user.send(:decrypt_token, private_key)

      get :show, params: { id: api_user.id }, xhr: true

      api_user.reload

      new_token = api_user.send(:decrypt_token, private_key)

      expect(api_user).to_not be_locked
      expect(api_user.authenticate(old_token)).to eq false
      expect(api_user.authenticate(new_token)).to eq true
    end
  end

  context 'DELETE destroy' do
    it 'user invalidates token' do
      delete :destroy, params: { id: api_user.id }

      api_user.reload

      token = api_user.send(:decrypt_token, private_key)

      expect(api_user).to be_locked
      expect(api_user.authenticate(token)).to eq false
    end
  end
end
