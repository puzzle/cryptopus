# frozen_string_literal: true

require 'rails_helper'

describe Session::OicdController do
  include ControllerHelpers

  context 'GET create' do

    it 'returns from external openid connect login and creates/logs in new user' do
      # expect session reset
    end

    it 'returns from external openid connect login and logs in existing user' do
    end

    it 'does not login user if given token ' do
    end
    # it 'logs in User with Keycloak' do
      # enable_keycloak
      # Rails.application.reload_routes!

      # expect(Keycloak::Client).to receive(:get_token_by_code)
        # .and_return('{ "access_token": "asd" }')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:get_attribute)
        # .with('pk_secret_base', 'asd')
        # .and_return('')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:get_attribute)
        # .with('preferred_username', 'asd')
        # .and_return('ben')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:get_attribute)
        # .with('given_name', 'asd')
        # .and_return('Ben')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:get_attribute)
        # .with('family_name', 'asd')
        # .and_return('Meier')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:get_attribute)
        # .with('sub', 'asd')
        # .and_return('1234')
        # .at_least(:once)
      # expect(Keycloak::Client).to receive(:user_signed_in?)
        # .and_return(true)
        # .at_least(:once)

      # get :create, params: { code: 'asd' }
      # expect(response).to redirect_to root_path
      # user = User.find_by(username: 'ben')
      # expect(user.username).to eq('ben')
      # expect(session['username']).to eq('ben')
      # expect(session['private_key']).to_not be_nil
    # end

    it 'redirects to oidc server if not logged in' do
      enable_openid_connect
      Rails.application.reload_routes!

      expect(Keycloak::Client)
        .to receive(:get_token_by_code)
        .and_return('{ "access_token": "asd" }')
      expect(Keycloak::Client)
        .to receive(:user_signed_in?)
        .and_return(false)
      expect(Keycloak::Client)
        .to receive(:url_login_redirect)
        .with('http://www.example.com' + sso_path, 'code')
        .and_return(sso_path)
        .at_least(:once)
      get :create, params: { code: 'asd' }
      expect(response).to redirect_to sso_path
    end

    it 'redirects to normal login if oidc disabled' do
      Rails.application.reload_routes!

      expect do
        get :create, params: { code: 'asd' }
      end.to raise_error(ActionController::UrlGenerationError)
    end

    it 'redirects to migration if user\'s auth is not oidc' do
      enable_keycloak
      Rails.application.reload_routes!

      expect(Keycloak::Client)
        .to receive(:user_signed_in?)
        .and_return(true)
        .at_least(:once)
      expect(Keycloak::Client)
        .to receive(:get_token_by_code)
        .and_return('{ "access_token": "asd" }')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('preferred_username', 'asd')
        .and_return('bob')
        .at_least(:once)
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('pk_secret_base', 'asd')
        .and_return('')
        .at_least(:once)

      get :create, params: { code: 'asd' }

      expect(response).to redirect_to recrypt_sso_path
    end
  end
end
