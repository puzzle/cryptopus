# encoding: utf-8

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class User::ApiTokenTest < ActiveSupport::TestCase

  context '#create' do

    test 'creates new token for human user' do
      @api_token = bob.api_tokens.create!(description: 'firefox plugin')

      token = decrypted_token
      assert_match /\A[a-z0-9]{32}\z/, token
      assert_equal true, @api_token.authenticate(token)
      assert_match /\Abob-[a-z0-9]{6}\z/, @api_token.username
      assert_equal 60, @api_token.valid_for
    end

    test 'creation fails if no human user assigned' do
      @api_token = User::ApiToken.create

      assert_equal false, @api_token.persisted?
      assert_match /can't be blank/, @api_token.errors.messages[:username].first
      assert_match /can't be blank/, @api_token.errors.messages[:human_user].first
    end

  end

  context '#renew' do

    test 'creates new token and updates expiring time' do
    end

  end

  context '#authenticate' do
  end

  private
  
  def bob
    users(:bob)
  end

  def decrypted_token
    @api_token.send(:decrypt_token, bobs_private_key)
  end

  def bobs_private_key
    bob.decrypt_private_key('password')
  end

end
