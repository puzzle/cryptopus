# frozen_string_literal: true

require 'rails_helper'

describe Authentication::AuthProvider do
  context 'db' do
    it 'authenticates bob' do
      @username = 'bob'
      @password = 'password'

      expect(authenticate!).to eq true
    end

    it 'fails authentication if username blank' do
      @username = ''
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'fails authentication if password blank' do
      @username = 'bob'
      @password = ''

      expect(authenticate!).to be false
    end

    it 'fails authentication if wrong password' do
      @username = 'bob'
      @password = 'invalid'

      expect(authenticate!).to be false
      expect(/Invalid user \/ password/).to match(authenticator.errors.first)
    end

    it 'fails authentication if no user for username' do
      @username = 'mrInvalid'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'fails authentication if username with special chars' do
      @username = 'invalid_username?'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'fails authentication if required params missing' do
      expect(authenticate!).to be false
      expect(/Invalid user \/ password/).to match(authenticator.errors.first)
    end

    it 'fails authentication if user does not exist' do
      @username = 'nobody'
      @password = 'password'

      expect(authenticate!).to be false
      expect(/Invalid user \/ password/).to match(authenticator.errors.first)
    end

    it 'fails authentication if user is locked' do
      bob.update!(locked: true)

      @username = 'bob'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'increases failed login attempts and it\'s defined time delays' do
      @username = 'bob'
      @password = 'wrong password'
      LOCKTIMES = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
      expect(10).to eq(Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length)

      LOCKTIMES.each_with_index do |_t, i|
        attempt = i + 1

        last_failed_login_time = Time.now.utc - LOCKTIMES[i].seconds
        bob.update!(last_failed_login_attempt_at: last_failed_login_time)

        expect(authenticator.send(:user_locked?)).to be false

        Authentication::AuthProvider.new(username: @username, password: @password).authenticate!

        if attempt == LOCKTIMES.count
          expect(bob.reload.locked?).to be true
          break
        end

        expect(attempt).to eq(bob.reload.failed_login_attempts)
        expect(last_failed_login_time.to_i).to be <= bob.last_failed_login_attempt_at.to_i
      end
    end

    it 'succeeds authentication if valid api token' do
      token = api_user.send(:decrypt_token, private_key)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = token

      expect(authenticate!).to be true
    end

    it 'fails authentication if api token is expired' do
      token = api_user.send(:decrypt_token, private_key)
      valid_for = 1.minute.seconds

      api_user.update!(valid_for: valid_for)
      api_user.update!(valid_until: Time.now.utc - 1.minute)
      @username = api_user.username
      @password = token

      expect(authenticate!).to be false
    end

    it 'succeeds authentication if api token is valid for infinite' do
      token = api_user.send(:decrypt_token, private_key)
      valid_for = 0

      api_user.update!(valid_for: valid_for)
      @username = api_user.username
      @password = token

      expect(authenticate!).to be true
    end

    it 'fails authentication if api token invalid' do
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = 'abcd'

      expect(authenticate!).to be false
    end

    it 'fails authentication if api token blank' do
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = ''

      expect(authenticate!).to be false
    end

    it 'fails authentication if api user is locked' do
      api_user.update!(locked: true)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)

      token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      @password = token

      expect(authenticate!).to be false
    end

    it 'fails authentication if api users human user is locked' do
      bob.update!(locked: true)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)

      token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      @password = token

      expect(api_user.locked?).to be true
      expect(authenticate!).to be false
    end
  end

  context 'keycloak' do
    it 'create user from Keycloak' do
      enable_keycloak
      expect(Keycloak::Client).to receive(:get_attribute)
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
        .and_return(true)
      expect(Keycloak::Admin).to receive(:get_user)
        .and_return('{}')
      expect(Keycloak::Client).to receive(:get_token_by_client_credentials)
        .and_return('{ "acess_token": "asd" }')

      Authentication::AuthProvider::Sso.new(username: 'ben').user
      user = User.find_by(username: 'ben')

      expect(user.username).to eq('ben')
      expect(user.givenname).to eq('Ben')
      expect(user.surname).to eq('Meier')
      expect(user.provider_uid).to eq('aw123')
    end

    it 'raises error because keycloak is not enabled' do
      expect do
        error = Authentication::AuthProvider::Sso.new(username: 'bob')
        expect(error.message).to eq('can\'t preform this action Keycloak is disabled')
      end.to raise_error(StandardError)
    end
  end

  context 'ldap' do
    it 'creates user from ldap' do
      enable_ldap
      ldap_mock = double

      expect(LdapConnection).to receive(:new).exactly(1).times.and_return(ldap_mock)
      expect(ldap_mock).to receive(:uidnumber_by_username).and_return('42')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'givenname').and_return('Ben')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'sn').and_return('test')
      expect(ldap_mock).to receive(:authenticate!).with('ben', 'password').and_return(true)

      Authentication::AuthProvider::Ldap.new(username: 'ben', password: 'password').user
      user = User.find_by(username: 'ben')

      expect(user.username).to eq('ben')
      expect(user.provider_uid).to eq('42')
      expect(user.givenname).to eq('Ben')
      expect(user.surname).to eq('test')
      expect(user.auth).to eq('ldap')
    end

    it 'raises error because ldap is not enabled' do
      expect do
        error = Authentication::AuthProvider::Ldap.new(username: 'bob')
        expect(error.message).to eq('can\'t preform this action Ldap is disabled')
      end.to raise_error(StandardError)
    end

    it 'succeeds ldap authentication with correct credentials' do
      enable_ldap
      mock_ldap_settings

      @username = 'bob'
      @password = 'ldappw'
      auth_provider = Authentication::AuthProvider::Ldap.new(username: 'bob', password: 'ldappw')
      bob.update!(auth: 'ldap')

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .twice
        .with('bob', 'ldappw')
        .and_return(true)
      expect(auth_provider.authenticate!).to be true
    end

    it 'fails ldap authentication if wrong password' do
      enable_ldap
      mock_ldap_settings

      bob.update!(auth: 'ldap')
      auth_provider = Authentication::AuthProvider::Ldap
                      .new(username: 'bob', password: 'wrongldappw')

      expect_any_instance_of(LdapConnection).to receive(:authenticate!)
        .with('bob', 'wrongldappw')
        .and_return(false)
      expect(auth_provider.authenticate!).to be false
    end

    it 'returns user if exists in db' do
      enable_ldap
      mock_ldap_settings
      expect_any_instance_of(LdapConnection).to receive(:authenticate!)
        .with('bob', 'ldappw')
        .and_return(true)

      user = Authentication::AuthProvider::Ldap.new(username: 'bob', password: 'ldappw').user
      expect(user).to_not be_nil
      expect(user.username).to eq('bob')
    end

    it 'does not return user if user not exists in db and ldap' do
      enable_ldap
      mock_ldap_settings

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('nobody', 'password').and_return(false)

      user = Authentication::AuthProvider::Ldap
             .new(username: 'nobody', password: 'password')
             .find_or_create_user
      expect(user).to be_nil
    end
  end

  private

  def authenticate!
    authenticator.authenticate!
  end

  def authenticator
    @authenticator ||= Authentication::AuthProvider.new(username: @username, password: @password)
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
