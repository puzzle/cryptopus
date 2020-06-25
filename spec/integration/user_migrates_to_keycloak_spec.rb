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
      .twice
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .twice
      .with('asd', sso_url)
      .and_return('token')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username')
      .and_return('bob')
      .exactly(8).times
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name')
      .at_least(:once)
      .and_return('Bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name')
      .at_least(:once)
      .and_return('Meister')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base')
      .exactly(3).times
      .and_return(@pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true, true, true, true, true, true)

    # login
    get search_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq(search_path)
    expect(response.body).to match(/Hi  Bob! Want to recover a password?/)
  end

  it 'migrates ldap bob to keycloak' do
    users(:bob).update!(auth: 'ldap', password: nil)
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .twice
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .twice
      .with('asd', sso_url)
      .and_return('token')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('sub')
      .at_least(:once)
      .and_return('asdQW123-asdQWE')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('preferred_username')
      .and_return('bob')
      .exactly(8).times
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('given_name')
      .at_least(:once)
      .and_return('Bob')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('family_name')
      .at_least(:once)
      .and_return('Meister')
    expect(Keycloak::Client).to receive(:get_attribute)
      .with('pk_secret_base')
      .exactly(3).times
      .and_return(@pk_secret_base)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .and_return(false, true, true, true, true, true, true, true)

    # login
    get search_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq(search_path)
    expect(response.body).to match(/Hi  Bob! Want to recover a password?/)
  end
end
