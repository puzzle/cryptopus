# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require_relative '../../../app/controllers/authentication/user_authenticator.rb'
require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class UserAuthenticatorTest < ActiveSupport::TestCase

  test 'authentication fails if required params missing' do
    @params = {}
    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication fails if invalid credentials' do
    @params = {username: 'bob', password: 'invalid'}
    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication fails if user does not exist' do
    @params = {username: 'nobody', password: 'password'}
    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication succeeds if user and password match' do
    @params = {username: 'bob', password: 'password'}
    assert_equal true, authenticate
  end

  private
  def authenticate
    authenticator.password_auth!
  end

  def authenticator
    @authenticator ||= UserAuthenticator.new(@params)
  end
end
