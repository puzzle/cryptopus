# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator::Sso do

  before(:each) do
    enable_keycloak
  end

  context 'keycloak' do
    it 'create user from Keycloak' do
      expect(Keycloak::Client).to receive(:get_attribute)
        .twice
        .with('sub', 'asd')
        .and_return('aw123')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('given_name', 'asd')
        .and_return('Ben')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('preferred_username', 'asd')
        .and_return('ben')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('family_name', 'asd')
        .and_return('Meier')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('pk_secret_base', 'asd')
        .and_return(nil)
      expect(Keycloak::Admin).to receive(:update_user)
        .and_return(true)
      expect(Keycloak::Client).to receive(:user_signed_in?)
        .twice
        .and_return(true)
      expect(Keycloak::Admin).to receive(:get_user)
        .and_return('{}')
      expect(Keycloak::Client).to receive(:get_token_by_client_credentials)
        .and_return('{ "access_token": "asd" }')

      @username = 'ben'

      @cookies = {}
      @cookies['keycloak_token'] = { access_token: 'asd' }.to_json

      expect(authenticate!).to be true
      user = User.find_by(username: 'ben')

      expect(user.username).to eq('ben')
      expect(user.givenname).to eq('Ben')
      expect(user.surname).to eq('Meier')
      expect(user.provider_uid).to eq('aw123')
    end

    it 'doesn\'t authenticate root' do
      @username = 'root'
      @password = 'password'

      @cookies = {}
      @cookies['keycloak_token'] = { access_token: 'asd' }.to_json

      expect(Keycloak::Client).to receive(:user_signed_in?)
        .and_return(false)
      expect(authenticate!).to be false
    end
  end

  private

  def authenticate!
    authenticator.authenticate!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.init(
      username: @username, password: @password, cookies: @cookies
    )
  end

  def api_user
    @api_user ||= bob.api_users.create
  end

  def bob
    users(:bob)
  end

  def private_key
    bob.decrypt_private_key('password')
  end
end

describe Keycloak do
  it 'has a version number' do
    expect(Keycloak::VERSION).not_to be nil
  end

  describe 'Module configuration' do
    describe '.installation_file=' do
      it 'should raise an error if given file does not exist' do
        expect do
          Keycloak.installation_file = 'random/file.json'
        end.to raise_error(Keycloak::InstallationFileNotFound)
      end
    end

    describe '.installation_file' do
      it 'should return default installation file' do
        expect(Keycloak.installation_file).to eq(Keycloak::KEYCLOAK_JSON_FILE)
      end

    end
  end
end
