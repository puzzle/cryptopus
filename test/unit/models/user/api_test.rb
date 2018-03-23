# encoding: utf-8

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class User::ApiTest < ActiveSupport::TestCase

  context '#create' do

    test 'creates new token for human user' do
      @api_user = bob.apis.create!(description: 'firefox plugin')

      token = decrypted_token
      assert_match /\A[a-z0-9]{32}\z/, token
      assert_equal true, @api_user.authenticate(token)
      assert_match /\Abob-[a-z0-9]{6}\z/, @api_user.username
      assert_equal 60, @api_user.valid_for
    end

    test 'creation fails if no human user assigned' do
      @api_user = User::Api.create

      assert_equal false, @api_user.persisted?
      assert_match /can't be blank/, @api_user.errors.messages[:username].first
      assert_match /can't be blank/, @api_user.errors.messages[:human_user].first
    end

    test 'creation fails for illegal options' do
      option_failure 42
      option_failure -20
      option_failure -1
    end

    test 'creation passes for all valid options' do
      option_success 1.minute.seconds
      option_success 5.minute.seconds
      option_success 12.hours.seconds
      option_success 0
    end
  end

  context '#renew' do

    test 'creates new token and updates expiring time' do
    end

  end

  context '#locked' do
    test 'user not locked' do
      @api_user = bob.apis.create

      assert_equal false, bob.locked?
      assert_equal false, @api_user.locked?
    end

    test 'api user locked' do
      @api_user = bob.apis.create

      @api_user.update_attribute(:locked, true)
      
      assert_equal false, bob.locked?
      assert_equal true, @api_user.locked?
    end

    test 'user locked' do
      @api_user = bob.apis.create

      bob.update_attribute(:locked, true)
      @api_user.reload

      assert_equal true, bob.locked?
      assert_equal true, @api_user.locked?
    end
  end

  context '#authenticate' do
  end

  private

  def option_success(seconds)
    @api_user = bob.apis.new(valid_for: seconds, description: 'api-access')

    assert_equal true, @api_user.valid?
    assert_equal seconds, @api_user.valid_for
  end

  def option_failure(seconds)
    @api_user = bob.apis.new(valid_for: seconds, description: 'api-access')
    assert_equal false, @api_user.valid?
    assert_match /is not included in the list/, @api_user.errors.messages[:valid_for].first
  end
  
  def bob
    users(:bob)
  end

  def decrypted_token
    @api_user.send(:decrypt_token, bobs_private_key)
  end

  def bobs_private_key
    bob.decrypt_private_key('password')
  end

end
