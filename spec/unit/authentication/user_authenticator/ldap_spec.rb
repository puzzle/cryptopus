# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator::Ldap do

  before(:each) do
    enable_ldap
  end

  let(:private_key) { users(:bob).decrypt_private_key('password') }

  context 'authenticate' do
    it 'creates user from ldap' do
      ldap_mock = double
      @username = 'ben'
      @password = 'password'

      expect(LdapConnection).to receive(:new).and_return(ldap_mock)
      expect(ldap_mock).to receive(:uidnumber_by_username).and_return('42')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'givenname').and_return('Ben')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'sn').and_return('test')
      expect(ldap_mock).to receive(:authenticate!).twice.with('ben', 'password').and_return(true)

      expect(authenticate!).to be true
      user = User.find_by(username: 'ben')

      expect(user.username).to eq('ben')
      expect(user.provider_uid).to eq('42')
      expect(user.givenname).to eq('Ben')
      expect(user.surname).to eq('test')
      expect(user.auth).to eq('ldap')
    end

    it 'succeeds ldap authentication with correct credentials' do
      @username = 'bob'
      @password = 'ldappw'
      bob.update!(auth: 'ldap')

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('bob', 'ldappw')
        .and_return(true)
      expect(authenticate!).to be true
    end

    it 'fails ldap authentication if wrong password' do
      @username = 'bob'
      @password = 'wrongldappw'
      bob.update!(auth: 'ldap')

      expect_any_instance_of(LdapConnection).to receive(:authenticate!)
        .with('bob', 'wrongldappw')
        .and_return(false)
      expect(authenticate!).to be false
    end

    it 'returns user if exists in db' do
      expect_any_instance_of(LdapConnection).to receive(:authenticate!)
        .with('bob', 'ldappw')
        .and_return(true)

      @username = 'bob'
      @password = 'ldappw'
      expect(authenticate!).to be true
      expect(authenticator.user).to_not be_nil
      expect(authenticator.user.username).to eq('bob')
    end

    it 'does not return user if user not exists in db and ldap' do

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('nobody', 'password')
        .exactly(2).times
        .and_return(false)
      @username = 'nobody'
      @password = 'password'
      expect(authenticate!).to be false
      expect(authenticator.user).to be_nil
    end

    it 'doesn\'t authenticate root' do
      @username = 'root'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'increases failed login attempts and it\'s defined time delays' do

      @username = 'bob'
      @password = 'wrong password'
      LOCKTIMES ||= [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
      expect(10).to eq(Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length)
      ldap = double
      expect(LdapConnection).to receive(:new).at_least(:once).and_return(ldap)
      expect(ldap)
        .to receive(:authenticate!)
        .exactly(10).times
        .with('bob', 'wrong password')
        .and_return(false)

      LOCKTIMES.each_with_index do |_t, i|
        attempt = i + 1

        last_failed_login_time = Time.now.utc - LOCKTIMES[i].seconds
        bob.update!(last_failed_login_attempt_at: last_failed_login_time)

        expect(authenticator.send(:brute_force_detector).locked?).to be false



        expect(Authentication::UserAuthenticator
          .init(username: @username, password: @password)
          .authenticate!).to be false

        if attempt == LOCKTIMES.count
          expect(bob.reload.locked?).to be true
          break
        end

        expect(attempt).to eq(bob.reload.failed_login_attempts)
        expect(last_failed_login_time.to_i).to be <= bob.last_failed_login_attempt_at.to_i
      end
    end
  end

  context 'api authenticate' do
    it 'succeeds ldap authentication with correct credentials' do
      @username = 'bob'
      @password = 'ldappw'
      bob.update!(auth: 'ldap')

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('bob', 'ldappw')
        .and_return(true)
      expect(authenticate_by_headers!).to be true
    end

    it 'fails ldap authentication if wrong password' do
      @username = 'bob'
      @password = 'wrongldappw'
      bob.update!(auth: 'ldap')

      expect_any_instance_of(LdapConnection).to receive(:authenticate!)
        .with('bob', 'wrongldappw')
        .and_return(false)
      expect(authenticate_by_headers!).to be false
    end

    it 'doesn\'t authenticate root' do
      @username = 'root'
      @password = 'password'

      expect(authenticate_by_headers!).to be false
    end

    it 'authenticates api users' do
      @username = api_user.username
      @password = api_user.send(:decrypt_token, private_key)
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      expect(authenticate_by_headers!).to be true
    end

    it 'fails authentication if wrong password' do
      @username = api_user.username
      @password = 'wrong_token'
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      expect(authenticate_by_headers!).to be false
    end
  end

  private

  def authenticate!
    authenticator.authenticate!
  end

  def authenticate_by_headers!
    authenticator.authenticate_by_headers!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.init(
      username: @username, password: @password
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
