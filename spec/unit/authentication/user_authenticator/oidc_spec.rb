# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator::Oidc do

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

  context '#authenticate!' do
    before do
      @code = '9854fb0a-9414-4385-a35d-37e982aad4ce.7ad42cae-5b68-4e3e-ba47-09f923281224.5534245e-0041-4a42-b973-c33a58977d21' # rubocop:disable Layout/LineLength
      @state = SecureRandom.hex(16)
      allow_any_instance_of(OidcClient).
        to receive(:get_id_token).and_return(id_token)
    end

    it 'creates new user on first login' do
      expect do
        expect(authenticate!).to be true
      end.to change { User::Human.count }.by(1)

      user = User.find_by(username: 'alex')

      expect(user.givenname).to eq('Alex')
      expect(user.surname).to eq('Honold')
      expect(user.provider_uid).to eq('377ada56-6ee6-48bc-8201-519568b64029')
      expect(user.auth).to eq('oidc')
      expect(user.oidc?).to be true
      expect(user.password).to be_nil

      # would raise an error if not working
      user.decrypt_private_key(user_passphrase)
    end

    it 'logs in existing user' do
      user = create_oidc_user(user_passphrase)

      expect do
        expect(authenticate!).to be true
      end.to change { User::Human.count }.by(0)

      user.reload
      expect(user.givenname).to eq('Alex')
      expect(user.surname).to eq('Honold')
      expect(user.auth).to eq('oidc')

      # would raise an error if not working
      user.decrypt_private_key(user_passphrase)
    end

    it 'auth fails if user_pk_secret_base missing' do
      create_oidc_user(user_passphrase)
      id_token_attrs['cryptopus_pk_secret_base'] = nil

      expect do
        authenticate!
      end.to raise_error(RuntimeError,
                         'openid connect id token: cryptopus_pk_secret_base not present or invalid')
    end

    it 'auth fails if user_pk_secret_base to short' do
      create_oidc_user(user_passphrase)
      id_token_attrs['cryptopus_pk_secret_base'] = 'abcd'

      expect do
        authenticate!
      end.to raise_error(RuntimeError,
                         'openid connect id token: cryptopus_pk_secret_base not present or invalid')
    end

    it 'never authenticates root' do
      user = User.find_by(username: 'root')
      id_token_attrs['preferred_username'] = 'root'

      expect(authenticate!).to be false

      user.reload
      expect(user.auth).to eq('db')
      expect(user.oidc?).to be false
    end

    it 'never authenticates api user' do
      oidc_user = create_oidc_user(user_passphrase)
      api_user = oidc_user.api_users.create
      id_token_attrs['preferred_username'] = api_user.username

      expect(authenticate!).to be false
    end
  end

  context '#authenticate_by_headers!' do
    it 'never authenticates root' do
      @username = 'root'
      @password = 'password'

      expect(authenticate_by_headers!).to be false
    end

    it 'never authenticates oidc user' do
      user = create_oidc_user(user_passphrase)

      @username = 'alex'
      @password = user_passphrase

      expect(user.reload.oidc?).to be true
      expect(authenticate_by_headers!).to be false
    end

    it 'authenticates api user that belongs to oidc user' do
      oidc_user = create_oidc_user(user_passphrase)
      api_user = oidc_user.api_users.create
      expect_any_instance_of(Authentication::UserAuthenticator::Db)
        .to receive(:authenticate_by_headers!).and_return(true)

      @username = api_user.username
      @password = 'api-user-token'

      expect(authenticate_by_headers!).to be true
    end

    it 'does not authenticate api user if wrong token' do
      oidc_user = create_oidc_user(user_passphrase)
      api_user = oidc_user.api_users.create

      @username = api_user.username
      @password = 'wrong'

      expect(authenticate_by_headers!).to be false
    end
  end

  private

  def authenticate!
    authenticator.authenticate!(code: @code, state: @state)
  end

  def authenticate_by_headers!
    authenticator.authenticate_by_headers!
  end

  def authenticator
    @authenticator ||= init_authenticator
  end

  def init_authenticator
    Authentication::UserAuthenticator
      .init(username: @username, password: @password)
  end

  def create_oidc_user(password)
    user = User::Human.new(givenname: 'Alex', surname: 'Honold', username: 'alex')
    user.auth = 'oidc'
    user.create_keypair password
    user.save!
    user
  end

end
