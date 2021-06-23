# frozen_string_literal: true

require 'spec_helper'

describe 'User migrates to oidc' do
  include IntegrationHelpers::DefaultHelper

  before do
    enable_openid_connect
    users(:bob).update!(auth: 'ldap')
  end

  let(:user_pk_secret_base) do
    'ea418d9dea874666b81a9a7b9002afc6a50c4ee1c281ed77233900077a92c709'
  end

  let(:user_passphrase) do
    pk_secret_base = Rails.application.secrets.secret_key_base
    Digest::SHA512.hexdigest(user_pk_secret_base + pk_secret_base)
  end

  let(:id_token_attrs) do
    { 'exp' => 1607583405,
      'iat' => 1607583105,
      'auth_time' => 1607581332,
      'jti' => '49aaf50c-a01b-4557-bb9e-b00c776fc873',
      'iss' => 'http =>//keycloak =>8180/auth/realms/cryptopus',
      'aud' => 'cryptopus',
      'sub' => '377ada56-6ee6-48bc-8201-519568b64029',
      'typ' => 'ID',
      'azp' => 'cryptopus',
      'nonce' => 'd384bd6ffffd720c7cd12d2a10eefb44',
      'session_state' => '7ad42cae-5b68-4e3e-ba47-09f923281224',
      'acr' => '0',
      'email_verified' => false,
      'cryptopus_pk_secret_base' => user_pk_secret_base,
      'name' => 'Bob Bobby',
      'preferred_username' => 'bob',
      'given_name' => 'Bob',
      'family_name' => 'Bobby' }
  end

  let(:id_token) do
    instance_double('IdToken', raw_attributes: id_token_attrs)
  end

  before do
    allow_any_instance_of(OidcClient)
      .to receive(:get_id_token)
      .and_return(id_token)
  end


  it 'migrates ldap user to oidc' do
    # 1. redirect to external openid connect login form
    get root_path
    redirect_url = response.location
    host, params = redirect_url.split('?')
    expect(host).to eq('https://oidc.example.com:8180/auth/realms/cryptopus/protocol/openid-connect/auth')
    params = URI.decode_www_form(params).to_h
    state = params['state']

    # 2. returning back from external login form to cryptopus
    get session_oidc_path, params: { code: 'abdc42', state: state }

    # 3. redirect to recrypt form and provides wrong old password
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/oidc')
    post recrypt_oidc_path, params: { old_password: 'wrong' }
    expect(request.fullpath).to eq('/recrypt/oidc')

    # 4. still on recrypt form and provides correct old password
    post recrypt_oidc_path, params: { old_password: 'password' }

    # 5. back to root path and external openid connect login
    follow_redirect!
    expect(request.fullpath).to eq('/')
    redirect_url = response.location
    host, params = redirect_url.split('?')
    expect(host).to eq('https://oidc.example.com:8180/auth/realms/cryptopus/protocol/openid-connect/auth')
    params = URI.decode_www_form(params).to_h
    state = params['state']

    # 6. returning back from external login form to cryptopus
    get session_oidc_path, params: { code: 'abdc42', state: state }

    # 7. user logged in
    follow_redirect!
    expect(request.fullpath).to eq(root_path)

    # user has now openid connect as auth
    expect(users(:bob).reload.auth).to eq('oidc')
  end
end
