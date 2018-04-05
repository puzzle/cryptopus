# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::ApiUsers::TokenControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper
  
  setup :login_as_bob, :create_api_user

  context '#update' do
    test 'user renews token' do
      old_token = @api_user.send(:decrypt_token, private_key)
      
      get :show, params: { id: @api_user.id }, xhr: true

      @api_user.reload

      new_token = @api_user.send(:decrypt_token, private_key)

      assert_equal false, @api_user.locked?
      assert_equal false, @api_user.authenticate(old_token)
      assert_equal true, @api_user.authenticate(new_token)
    end
  end
  
  context '#destroy' do
    test 'user invalidates token' do
      delete :destroy, params: { id: @api_user.id }

      @api_user.reload
      
      token = @api_user.send(:decrypt_token, private_key)

      assert_equal true, @api_user.locked?
      assert_equal false, @api_user.authenticate(token)
    end
  end

  private
  
  def create_api_user
    @api_user = users(:bob).api_users.create!(description: 'my sweet api user')
  end
  
  def login_as_bob
    login_as(:bob)
  end

  def private_key
    users(:bob).decrypt_private_key('password')
  end
end
