# frozen_string_literal: true

require 'spec_helper'

describe Authentication::UserAuthenticator::Db do
  context 'human user' do
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
    end

    it 'fails authentication if user does not exist' do
      @username = 'nobody'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'fails authentication if user is locked' do
      bob.update!(locked: true)

      @username = 'bob'
      @password = 'password'

      expect(authenticate!).to be false
    end

    it 'fails authentication if api user' do
      token = api_user.send(:decrypt_token, private_key)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = token

      expect(api_user.authenticate_db(token)).to be true
      expect(authenticate!).to be false
    end

    it 'increases failed login attempts and it\'s defined time delays' do
      @username = 'bob'
      @password = 'wrong password'
      locktimes = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
      expect(10).to eq(Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length)

      locktimes.each_with_index do |_t, i|
        attempt = i + 1

        last_failed_login_time = Time.now.utc - locktimes[i].seconds
        bob.update!(last_failed_login_attempt_at: last_failed_login_time)

        expect(authenticator.send(:brute_force_detector).locked?).to be false

        Authentication::UserAuthenticator
          .init(username: @username, password: @password)
          .authenticate!

        if attempt == locktimes.count
          expect(bob.reload.locked?).to be true
          break
        end

        expect(attempt).to eq(bob.reload.failed_login_attempts)
        expect(last_failed_login_time.to_i).to be <= bob.last_failed_login_attempt_at.to_i
      end
    end
  end

  context 'api user' do
    it 'succeeds authentication if valid api token' do
      token = api_user.send(:decrypt_token, private_key)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = token

      expect(authenticate_by_headers!).to be true
    end

    it 'fails authentication if api token is expired' do
      token = api_user.send(:decrypt_token, private_key)
      valid_for = 1.minute.seconds

      api_user.update!(valid_for: valid_for)
      api_user.update!(valid_until: Time.now.utc - 1.minute)
      @username = api_user.username
      @password = token

      expect(authenticate_by_headers!).to be false
    end

    it 'succeeds authentication if api token is valid for infinite' do
      token = api_user.send(:decrypt_token, private_key)
      valid_for = 0

      api_user.update!(valid_for: valid_for)
      @username = api_user.username
      @password = token

      expect(authenticate_by_headers!).to be true
    end

    it 'fails authentication if api token invalid' do
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = 'abcd'

      expect(authenticate_by_headers!).to be false
    end

    it 'fails authentication if api token blank' do
      api_user.update!(valid_until: Time.now.utc + 5.minutes)
      @username = api_user.username
      @password = ''

      expect(authenticate_by_headers!).to be false
    end

    it 'fails authentication if api user is locked' do
      api_user.update!(locked: true)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)

      token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      @password = token

      expect(authenticate_by_headers!).to be false
    end

    it 'fails authentication if api users human user is locked' do
      bob.update!(locked: true)
      api_user.update!(valid_until: Time.now.utc + 5.minutes)

      token = api_user.send(:decrypt_token, private_key)
      @username = api_user.username
      @password = token

      expect(api_user.locked?).to be true
      expect(authenticate_by_headers!).to be false
    end

    it 'authenticates root' do
      @username = 'root'
      @password = 'password'
      expect(db_authenticator.authenticate!(allow_root: true)).to be true
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

  def authenticate_by_headers!
    authenticator.authenticate_by_headers!
  end

  def db_authenticator
    @db_authenticator ||= Authentication::UserAuthenticator::Db.new(
      username: @username, password: @password
    )
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
