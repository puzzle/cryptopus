# frozen_string_literal: true

require 'spec_helper'

describe Api::Profile::PasswordController do
  include ControllerHelpers

  let(:api_user) { users(:alice).api_users.create! }

  context 'POST update_password' do
    it 'updates password' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(json['info']).to include('flashes.profile.changePassword.success')
      expect(users(:bob).authenticate_db('test')).to eq true
    end

    it 'updates password, error if oldpassword not match' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'wrong_password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(json['errors']).to include('helpers.label.user.wrongPassword')
      expect(users(:bob).authenticate_db('test')).to be false
    end

    it 'updates password, error if new passwords not match' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'wrong_password' }
        }
      }
      patch :update, params: password_params

      expect(json['errors']).to include('flashes.profile.changePassword.new_passwords_not_equal')
      expect(users(:bob).authenticate_db('test')).to eq false
    end

    it 'returns unauthorized if ldap user tries to update password' do
      users(:bob).update!(auth: 'ldap')
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(response).to have_http_status(403)
    end

    it 'returns unauthorized if oidc user tries to update password' do
      users(:bob).update!(auth: 'oidc')
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(response).to have_http_status(403)
    end

    it 'returns unauthorized if api user tries to update password' do
      login_as_api_user
      password_params = {
        data: {
          attributes: { old_password: api_user_token,
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(response).to have_http_status(403)
    end
  end

  private

  def login_as_api_user
    api_user.update!(valid_until: Time.zone.now + 5.minutes)
    request.headers['Authorization-User'] = api_user.username
    request.headers['Authorization-Password'] = api_user_token
  end

  def api_user_token
    private_key = users(:alice).decrypt_private_key('password')
    decrypted_token = api_user.send(:decrypt_token, private_key)
    Base64.encode64(decrypted_token)
  end
end
