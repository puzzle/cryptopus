# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

#require_relative '../../../app/controllers/authentication/user_authenticator.rb'
#require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class ApiTokenAuthenticatorTest < ActiveSupport::TestCase

  test 'authenticates valid api token' do
  end

  test 'authentication fails if api token expired' do
  end

  test 'authentication fails if api token invalid' do
  end

  test 'authentication fails if api user invalid' do
  end

  test 'authentication fails if required headers blank' do
  end

  #test 'authenticates bob' do
    #@params = {username: 'bob', password: 'password'}

    #assert_equal true, authenticate
  #end

  #test 'authentication invalid if blank password' do
    #@params = {username: 'bob', password: ''}

    #assert_equal false, authenticate
  #end

  #test 'authentication invalid if username with special chars' do
    #@params = {username: 'invalid_username?', password: 'test'}

    #assert_equal false, authenticate
  #end

  #test 'ldap authentication succeeds with correct user/password' do
    #enable_ldap
    #@params = {username: 'bob', password: 'ldappw'}
    #bob.update_attribute(:auth, 'ldap')
    #LdapConnection.any_instance.expects(:login).with('bob', 'ldappw').returns(true)
    #assert_equal true, authenticate
  #end

  #test 'ldap authentication fails if wrong password' do
    #enable_ldap
    #@params = {username: 'bob', password: 'wrongldappw'}
    #bob.update_attribute(:auth, 'ldap')
    #LdapConnection.any_instance.expects(:login).with('bob', 'wrongldappw').returns(false)

    #assert_equal false, authenticate
  #end

  #test 'increasing of failed login attempts and it\'s defined delays' do
    #@params = {username: 'bob', password: 'wrong password'}
    #LOCKTIMES = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
    #assert_equal 10, Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT.length

    #LOCKTIMES.each_with_index do |timer, i|
      #attempt = i + 1

      #last_failed_login_time = DateTime.now.utc - LOCKTIMES[i].seconds
      #bob.update!({last_failed_login_attempt_at: last_failed_login_time})

      #assert_equal false, authenticator.send(:user_locked?), 'bob should should not be locked temporarly'

      #Authentication::UserPasswordAuthenticator.new(@params).auth!

      #if attempt == LOCKTIMES.count
        #assert_equal true, bob.reload.locked?, 'bob should be logged after 10 failed login attempts'
        #break
      #end

      #assert_equal attempt, bob.reload.failed_login_attempts
      #assert last_failed_login_time.to_i <= bob.last_failed_login_attempt_at.to_i

    #end
  #end

  #test 'authentication fails if required params missing' do
    #@params = {}

    #assert_equal false, authenticate
    #assert_match /Invalid user \/ password/, authenticator.errors.first
  #end

  #test 'authentication fails if invalid credentials' do
    #@params = {username: 'bob', password: 'invalid'}

    #assert_equal false, authenticate
    #assert_match /Invalid user \/ password/, authenticator.errors.first
  #end

  #test 'authentication fails if user does not exist' do
    #@params = {username: 'nobody', password: 'password'}

    #assert_equal false, authenticate
    #assert_match /Invalid user \/ password/, authenticator.errors.first
  #end

  #test 'authentication succeeds if user and password match' do
    #@params = {username: 'bob', password: 'password'}

    #assert_equal true, authenticate
  #end

  private
  def authenticate
    authenticator.auth!
  end

  def authenticator
    @authenticator ||= Authentication::ApiTokenAuthenticator.new(@headers)
  end

  #def bob
    #users(:bob)
  #end
end
