# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

#require_relative '../../../app/controllers/authentication/user_authenticator.rb'
#require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class Authentication::UserAuthenticatorTest < ActiveSupport::TestCase

  test 'authenticates bob' do
     @username = 'bob'
     @password = 'password'

    assert_equal true, authenticate
  end
  
  test 'authentication fails if username blank' do
    @username = ''
    @password = 'password'

    assert_equal false, authenticate
  end

  test 'authentication fails if password blank' do
    @username = 'bob'
    @password = ''

    assert_equal false, authenticate
  end
  
  test 'authentication fails if wrong password' do
    @username = 'bob'
    @password = 'invalid'

    assert_equal false, authenticate
    assert_match(/Invalid user \/ password/, authenticator.errors.first)
  end

  test 'authentication fails if username with special chars' do
    @username = 'invalid_username?'
    @password ='password'

    assert_equal false, authenticate
  end
  
  test 'authentication fails if required params missing' do
    assert_equal false, authenticate
    assert_match(/Invalid user \/ password/, authenticator.errors.first)
  end

  test 'authentication fails if user does not exist' do
    @username = 'nobody'
    @password = 'password'

    assert_equal false, authenticate
    assert_match(/Invalid user \/ password/, authenticator.errors.first)
  end
  
  test 'authentication fails if user is locked' do
    bob.update!(locked: true)
    
    @username = 'bob'
    @password = 'password'

    assert_equal false, authenticate
  end

  test 'ldap authentication succeeds with correct credentials' do
    enable_ldap
    @username = 'bob'
    @password = 'ldappw'
    bob.update_attribute(:auth, 'ldap')
    LdapConnection.any_instance.expects(:login).with('bob', 'ldappw').returns(true)

    assert_equal true, authenticate
  end

  test 'ldap authentication fails if wrong password' do
    enable_ldap
    @username = 'bob'
    @password = 'wrongldappw'
    bob.update_attribute(:auth, 'ldap')
    LdapConnection.any_instance.expects(:login).with('bob', 'wrongldappw').returns(false)

    assert_equal false, authenticate
  end

  test 'increasing of failed login attempts and it\'s defined delays' do
    @username = 'bob'
    @password = 'wrong password'
    LOCKTIMES = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
    assert_equal 10, Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length

    LOCKTIMES.each_with_index do |timer, i|
      attempt = i + 1

      last_failed_login_time = DateTime.now.utc - LOCKTIMES[i].seconds
      bob.update!({last_failed_login_attempt_at: last_failed_login_time})

      assert_equal false, authenticator.send(:user_locked?), 'bob should should not be locked temporarly'

      Authentication::UserAuthenticator.new(username: @username, password: @password).auth!

      if attempt == LOCKTIMES.count
        assert_equal true, bob.reload.locked?, 'bob should be logged after 10 failed login attempts'
        break
      end

      assert_equal attempt, bob.reload.failed_login_attempts
      assert last_failed_login_time.to_i <= bob.last_failed_login_attempt_at.to_i
    end
  end

  test 'authentication success if valid api token' do
    token = api_user.send(:decrypt_token, private_key)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @username = api_user.username
    @password = token

    assert_equal true, authenticate
  end
 
  test 'authentication fails if api token expired' do
    token = api_user.send(:decrypt_token, private_key)
    valid_for = 1.minute.seconds
    
    api_user.update!(valid_for: valid_for)
    api_user.update!(valid_until: DateTime.now - 1.minute)
    @username = api_user.username
    @password = token

    assert_equal false, authenticate
  end
  
  test 'authentication success if api token valid for infinite' do
    token = api_user.send(:decrypt_token, private_key)
    valid_for = 0

    api_user.update!(valid_for: valid_for)
    @username = api_user.username
    @password = token

    assert_equal true, authenticate
  end
  
  test 'authentication fails if api token invalid' do
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @username = api_user.username
    @password = 'abcd'

    assert_equal false, authenticate
  end
  
  test 'authentication fails if api token blank' do
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @username = api_user.username
    @password = ''

    assert_equal false, authenticate
  end

  test 'authentication fails if api user is locked' do
    api_user.update!(locked: true)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    
    token = api_user.send(:decrypt_token, private_key)
    @username = api_user.username
    @password = token

    assert_equal false, authenticate
  end
  
  test 'authentication fails if api users human user is locked' do
    bob.update!(locked: true)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    
    token = api_user.send(:decrypt_token, private_key)
    @username = api_user.username
    @password = token

    assert_equal true, api_user.locked?
    assert_equal false, authenticate
  end

  private

  def authenticate
    authenticator.auth!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.new(username: @username, password: @password)
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
