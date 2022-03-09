# frozen_string_literal: true

require 'spec_helper'

describe Api::ApiUsers::TokenController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:api_user) { bob.api_users.create!(description: 'my sweet api user') }
  let(:api_user2) { bob.api_users.create!(description: 'my sweet second api user') }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET show' do
    context 'as human user' do
      before(:each) do
        login_as(:bob)
      end

      it 'renews token of api user' do
        old_token = api_user.send(:decrypt_token, bobs_private_key)

        get :show, params: { id: api_user.id }, xhr: true

        api_user.reload

        new_token = api_user.send(:decrypt_token, bobs_private_key)
        expect(api_user).to_not be_locked
        expect(old_token).to_not eq(new_token)
      end

      it 'renews token of api user and can still decrypt team password' do
        team = teams(:team1)
        credentials1 = encryptables(:credentials1)

        decrypted_team_password = team.decrypt_team_password(bob, bobs_private_key)
        team.add_user(api_user, decrypted_team_password)

        old_token = api_user.send(:decrypt_token, bobs_private_key)
        api_user_pk_before = api_user.decrypt_private_key(old_token)

        get :show, params: { id: api_user.id }, xhr: true

        api_user.reload

        received_token = json['token']
        token = api_user.send(:decrypt_token, bobs_private_key)

        expect(received_token).to eq(token)
        expect(api_user.authenticate_db(token)).to be true

        api_user_pk = api_user.decrypt_private_key(received_token)

        expect(api_user_pk_before).to eq(api_user_pk)

        decrypted_team_password = team.decrypt_team_password(api_user, api_user_pk)

        credentials1.decrypt(decrypted_team_password)

        expect(credentials1.cleartext_username).to eq 'test'
        expect(credentials1.cleartext_password).to eq 'password'
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
        old_token = api_user.send(:decrypt_token, bobs_private_key)

        get :show, params: { id: api_user.id }, xhr: true

        api_user.reload

        new_token = api_user.send(:decrypt_token, bobs_private_key)
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

      @token = api_user.send(:decrypt_token, bobs_private_key)
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
    decrypted_token = api_user.send(:decrypt_token, bobs_private_key)
    Base64.encode64(decrypted_token)
  end
end
