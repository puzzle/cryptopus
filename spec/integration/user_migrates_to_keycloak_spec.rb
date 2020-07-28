# frozen_string_literal: true

require 'rails_helper'

describe 'User migrates to keycloak spec' do
  include IntegrationHelpers::DefaultHelper

  before do
    enable_keycloak
    Rails.application.reload_routes!
    @pk_secret_base = SecureRandom.base64(32)
  end

  it 'migrates db bob to keycloak' do
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .at_least(:once)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .at_least(:once)
      .and_return(token)
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub', 'token')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username', 'token')
      .at_least(:once)
      .and_return('bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name', 'token')
      .at_least(:once)
      .and_return('Bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name', 'token')
      .at_least(:once)
      .and_return('Meister')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base', 'token')
      .at_least(:once)
      .and_return(@pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true, true, true, true, true, true)

    # login
    get root_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    # Adjust test to new start-page:
    expect(request.fullpath).to eq(root_path)
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end

  it 'migrates ldap bob to keycloak' do
    users(:bob).update!(auth: 'ldap', password: nil)
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .at_least(:once)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .at_least(:once)
      .and_return(token)
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub', 'token')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username', 'token')
      .at_least(:once)
      .and_return('bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name', 'token')
      .at_least(:once)
      .and_return('Bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name', 'token')
      .at_least(:once)
      .and_return('Meister')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base', 'token')
      .at_least(:once)
      .and_return(@pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true, true, true, true, true, true)

    # login
    get root_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    # Adjust test to new start-page:
    expect(request.fullpath).to eq(root_path)
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end

  private

  def token
    { access_token: 'token',
      expires_in: 300,
      refresh_expires_in: 1800,
      refresh_token: 'refresh_token' }.to_json
  end
end
