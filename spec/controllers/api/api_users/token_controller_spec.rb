# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::TokenController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET show' do
    it 'user renews token' do
      @token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username

      get :show, params: { id: api_user.id }, xhr: true

      api_user.reload

      expect(api_user).to_not be_locked
      expect(authenticate!).to be false
      @token = api_user.send(:decrypt_token, private_key)
      expect(authenticate!).to be true
    end

    it 'user cannot renew token of foreign_api_user' do
      get :show, params: { id: foreign_api_user.id }, xhr: true

      expect(response).to have_http_status(403)
    end
  end

  context 'DELETE destroy' do
    it 'user invalidates token' do
      delete :destroy, params: { id: api_user.id }

      api_user.reload

      @token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      expect(api_user).to be_locked
      expect(authenticate!).to be false
    end

    it 'user cannot invalidate token of foreign_api_user' do
      delete :destroy, params: { id: foreign_api_user.id }

      expect(response).to have_http_status(403)
    end
  end

  private

  def authenticate!
    authenticator.authenticate!
  end

  def authenticator
    Authentication::UserAuthenticator::Db.new(username: @username, password: @token)
  end
end
