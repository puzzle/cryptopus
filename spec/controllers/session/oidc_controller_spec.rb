# frozen_string_literal: true

require 'spec_helper'

describe Session::OidcController do
  include ControllerHelpers

  before do
    enable_openid_connect
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
      'name' => 'Alex Honold',
      'preferred_username' => 'alex',
      'given_name' => 'Alex',
      'family_name' => 'Honold' }
  end

  let(:id_token) do
    instance_double('IdToken', raw_attributes: id_token_attrs)
  end

  context 'GET create' do

    it 'returns from external openid connect login and creates/logs in new user' do
      expect_any_instance_of(OidcClient).to receive(:get_id_token).and_return(id_token)

      expect do
        get :create, params: { code: 'asd', state: 'haha' }, session: { oidc_state: 'haha' }
      end.to change { User::Human.count }.by(1)

      expect(response).to redirect_to root_path

      user = User.find_by(username: 'alex')
      expect(user.givenname).to eq('Alex')
      expect(session['username']).to eq('alex')
      expect(session['private_key']).to_not be_nil
    end

    it 'protects from csrf attack' do
      expect do
        get :create, params: { code: 'asd',
                               state: 'csrf-attacking' }, session: { oidc_state: 'haha' }
      end.to raise_error(RuntimeError, 'openid connect csrf protection state invalid')
    end

    it 'returns from external openid connect login and logs in existing user' do
      expect_any_instance_of(OidcClient).to receive(:get_id_token).and_return(id_token)
      user = create_oidc_user(user_passphrase)

      expect do
        get :create, params: { code: 'asd', state: 'haha' }, session: { oidc_state: 'haha' }
      end.to change { User::Human.count }.by(0)

      expect(response).to redirect_to root_path

      expect(user.username).to eq('alex')
      expect(user.givenname).to eq('Alex')
      expect(session['username']).to eq('alex')
      expect(session['private_key']).to_not be_nil
    end

    it 'redirects to recrypt form if existing user migrating' do
      expect_any_instance_of(OidcClient).to receive(:get_id_token).and_return(id_token)
      user = users(:bob)
      id_token_attrs['preferred_username'] = 'bob'

      expect do
        get :create, params: { code: 'asd', state: 'haha' }, session: { oidc_state: 'haha' }
      end.to change { User::Human.count }.by(0)

      expect(response).to redirect_to recrypt_oidc_path

      user.reload
      expect(user.username).to eq('bob')
      expect(user.auth).to eq('db')
      expect(session['username']).to eq('bob')
      expect(session['private_key']).to be_nil
    end

    it 'raises error if oidc disabled' do
      enable_db_auth
      expect do
        get :create, params: { code: 'asd' }
      end.to raise_error(ActionController::UrlGenerationError)
    end
  end

  private

  def create_oidc_user(password)
    user = User::Human.new(givenname: 'Alex', surname: 'Honold', username: 'alex')
    user.auth = 'oidc'
    user.create_keypair password
    user.save!
    user
  end
end
