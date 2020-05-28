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
        .with('sub')
        .and_return('aw123')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('given_name')
        .and_return('Ben')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('family_name')
        .and_return('Meier')
      expect(Keycloak::Client).to receive(:get_attribute)
        .with('pk_secret_base')
        .at_least(:once)
        .and_return(nil)
      expect(Keycloak::Admin).to receive(:update_user)
        .and_return(true)
      expect(Keycloak::Client).to receive(:user_signed_in?)
        .twice
        .and_return(true)
      expect(Keycloak::Admin).to receive(:get_user)
        .and_return('{}')
      expect(Keycloak::Client).to receive(:get_token_by_client_credentials)
        .and_return('{ "acess_token": "asd" }')

      @username = 'ben'
      expect(authenticate!).to be true
      user = User.find_by(username: 'ben')

      expect(user.username).to eq('ben')
      expect(user.givenname).to eq('Ben')
      expect(user.surname).to eq('Meier')
      expect(user.provider_uid).to eq('aw123')
    end

    it 'authenticates root' do
      @username = 'root'
      @password = 'password'
      expect(authenticator.root_authenticate!).to be true
    end

    it 'doesn\'t authenticate root' do
      @username = 'root'
      @password = 'password'
      expect(authenticate!).to be false
    end
  end

  private

  def authenticate!
    authenticator.authenticate!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.init(username: @username, password: @password)
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
