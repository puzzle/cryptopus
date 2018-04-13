# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

#require_relative '../../../app/controllers/authentication/api_user_authenticator.rb'
#require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class Authentication::ApiUserAuthenticatorTest < ActiveSupport::TestCase

  test 'authenticates valid api token' do
    token = api_user.send(:decrypt_token, private_key)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => token }

    assert_equal true, authenticate
  end
  
  test 'authentication fails if api token expired' do
    token = api_user.send(:decrypt_token, private_key)
    api_user.update!(valid_until: DateTime.now - 5.minutes)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => token }

    assert_equal false, authenticate
  end
  
  test 'authentication fails if api token invalid' do
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => 'abcd' }

    assert_equal false, authenticate
  end
  
  test 'authentication fails if api token nil' do
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => nil }

    assert_equal false, authenticate
  end

  test 'authentication fails if api user not exists' do
    @headers = { 'HTTP_API_USER' => 'bob-abcd', 'HTTP_API_TOKEN' => 'abcd' }

    assert_equal false, authenticate
  end

  test 'authentication fails if human user' do
    @headers = { 'HTTP_API_USER' => bob.username, 'HTTP_API_TOKEN' => 'password' }

    assert_equal false, authenticate
  end

  test 'authentication fails if required headers blank' do
    @headers = { }

    assert_equal false, authenticate
  end

  test 'authentication fails if api user is locked' do
    api_user.update!(locked: true)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    
    token = api_user.send(:decrypt_token, private_key)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => token }

    assert_equal false, authenticate
  end
  
  test 'authentication fails if api users human user is locked' do
    bob.update!(locked: true)
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    
    token = api_user.send(:decrypt_token, private_key)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => token }

    assert_equal true, api_user.locked?
    assert_equal false, authenticate
  end
  
  test 'increasing of failed login attempts and it\'s defined delays' do
    api_user.update!(valid_until: DateTime.now + 5.minutes)
    @headers = { 'HTTP_API_USER' => api_user.username, 'HTTP_API_TOKEN' => 'wrong password'}
    LOCKTIMES = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
    assert_equal 10, Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length

    LOCKTIMES.each_with_index do |timer, i|
      attempt = i + 1

      last_failed_login_time = DateTime.now.utc - LOCKTIMES[i].seconds
      api_user.update!({last_failed_login_attempt_at: last_failed_login_time})

      assert_equal false, authenticator.send(:user_locked?)

      Authentication::ApiUserAuthenticator.new(@headers).auth!

      if attempt == LOCKTIMES.count
        assert_equal true, api_user.reload.locked?
        break
      end

      assert_equal attempt, api_user.reload.failed_login_attempts
      assert last_failed_login_time.to_i <= api_user.last_failed_login_attempt_at.to_i
    end
  end
  
  private

  def authenticate
    authenticator.auth!
  end

  def authenticator
    @authenticator ||= Authentication::ApiUserAuthenticator.new(@headers)
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
