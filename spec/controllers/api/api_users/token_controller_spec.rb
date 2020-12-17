# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::TokenController do
  include ControllerHelpers

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:api_user2) { users(:bob).api_users.create!(description: 'my sweet second api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET show' do
    context 'as human user' do
      before(:each) do
        login_as(:bob)
      end

      it 'renews token of api user' do
        old_token = api_user.send(:decrypt_token, private_key)

        get :show, params: { id: api_user.id }, xhr: true

        api_user.reload

        new_token = api_user.send(:decrypt_token, private_key)
        expect(api_user).to_not be_locked
        expect(old_token).to_not eq(new_token)
      end

      it 'user cannot renew token of foreign_api_user' do
        get :show, params: { id: foreign_api_user.id }, xhr: true

        expect(response).to have_http_status(403)
      end
    end

    context 'as api user' do
      before(:each) do
        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token
        api_user.update!(valid_until: Time.zone.now + 5.minutes)
      end

      it 'renews token of himself' do
        old_token = api_user.send(:decrypt_token, private_key)

        get :show, params: { id: api_user.id }, xhr: true

        api_user.reload

        new_token = api_user.send(:decrypt_token, private_key)
        expect(old_token).to_not eq(new_token)
      end

      it 'cannot renew token of foreign_api_user' do
        get :show, params: { id: foreign_api_user.id }, xhr: true

        expect(response).to have_http_status(403)
      end

      it 'cannot renew token of different api user' do
        get :show, params: { id: api_user2.id }, xhr: true

        expect(response).to have_http_status(403)
      end
    end
  end

  context 'DELETE destroy' do
    it 'user invalidates token' do
      delete :destroy, params: { id: api_user.id }

      api_user.reload

      @token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      expect(api_user).to be_locked
    end

    it 'user cannot invalidate token of foreign_api_user' do
      delete :destroy, params: { id: foreign_api_user.id }

      expect(response).to have_http_status(401)
    end
  end

  private

  def token
    decrypted_token = api_user.send(:decrypt_token, private_key)
    Base64.encode64(decrypted_token)
  end
end
