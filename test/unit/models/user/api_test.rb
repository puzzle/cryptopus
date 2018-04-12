# encoding: utf-8

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class User::ApiTest < ActiveSupport::TestCase

  context '#create' do

    test 'creates new token for human user' do
      api_user = bob.api_users.create!(description: 'firefox plugin')

      token = decrypted_token(api_user)
      assert_match(/\A[a-z0-9]{32}\z/, token)
      assert_equal(true, api_user.authenticate(token))
      assert_match(/\Abob-[a-z0-9]{6}\z/, api_user.username)
      assert_equal(60, api_user.valid_for)
    end

    test 'creation fails if no human user assigned' do
      api_user = User::Api.create

      assert_equal(false, api_user.persisted?)
      assert_match(/can't be blank/, api_user.errors.messages[:username].first)
      assert_match(/can't be blank/, api_user.errors.messages[:human_user].first)
    end

    test 'invalid value for valid_for option' do
      api_user = bob.api_users.new(description: 'api-access')

      [42 -20 -1].each do |v|
        api_user.valid_for = v
        assert_equal(false, api_user.valid?)
        assert_match(/is not included in the list/, api_user.errors.messages[:valid_for].first)
      end
    end

    test 'valid value for valid_for option' do
      api_user = bob.api_users.new(description: 'api-access')

      [1.minute.seconds, 5.minute.seconds,
       12.hours.seconds, 0].each do |v|
        api_user.valid_for = v
        assert_equal true, api_user.valid?
        assert_equal v, api_user.valid_for
      end
    end
  end

  context '#renew' do

    test 'creates new token and updates expiring time' do
      now = Time.now
      api_user = bob.api_users.create!
      api_user.options.valid_for = 5.minutes.seconds
      api_user.options.valid_until = now

      Time.expects(:now).at_least_once.returns(now)

      new_token = api_user.renew_token(bob.decrypt_private_key('password'))

      assert_equal now.advance(seconds: 5.minutes.seconds).to_i, api_user.valid_until.to_i
      assert_equal true, api_user.authenticate(new_token)
      assert_equal new_token, decrypted_token(api_user)
      assert_equal false, api_user.locked?
    end

  end

  context '#locked' do
    test 'api user not locked' do
      api_user = bob.api_users.create

      assert_equal false, bob.locked?
      assert_equal false, api_user.locked?
    end

    test 'api user locked' do
      api_user = bob.api_users.create

      api_user.update!(locked: true)
      
      assert_equal false, bob.locked?
      assert_equal true, api_user.locked?
    end

    test 'human user locked' do
      api_user = bob.api_users.create

      bob.update!(locked: true)
      api_user.reload

      assert_equal true, bob.locked?
      assert_equal true, api_user.locked?
    end
  end
  
  context '#expired' do
    test 'api user not expired' do
      api_user = bob.api_users.create

      api_user.update!(valid_until: DateTime.now + 5.minutes)

      assert_equal false, api_user.expired?
    end

    test 'api user expired' do
      api_user = bob.api_users.create

      api_user.update!(valid_until: DateTime.now - 5.minutes)
      
      assert_equal true, api_user.expired?
    end
    
    test 'api user expired if valid until nil' do
      api_user = bob.api_users.create
      
      assert_nil api_user.valid_until
      assert_equal true, api_user.expired?
    end
  end

  context '#authenticate' do
    test 'api user authenticates with valid password' do
      api_user = bob.api_users.create
      
      token = decrypted_token(api_user)
      
      assert_equal true, api_user.authenticate(token)
    end

    test 'api user cannot authenticate with invalid password' do
      api_user = bob.api_users.create
      
      assert_equal false, api_user.authenticate('abcd')
    end

    test 'api user cannot authenticate if locked' do
      api_user = bob.api_users.create
      api_user.update!(locked: true)
      
      token = decrypted_token(api_user)
      
      assert_equal false, api_user.authenticate(token)
    end
  end

  private
  
  def bob
    users(:bob)
  end

  def decrypted_token(api_user)
    api_user.send(:decrypt_token, bobs_private_key)
  end

  def bobs_private_key
    bob.decrypt_private_key('password')
  end
end
