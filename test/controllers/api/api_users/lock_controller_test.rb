# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::ApiUsers::LockControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper
  setup :login_as_bob, :create_api_user
  
  context '#lock' do
    test 'user locks his api user' do
      post :create, params: { id: @api_user.id }, xhr: true

      @api_user.reload

      assert_equal true, @api_user.read_attribute(:locked)
    end
    
    test 'user cannot lock a foreign api user' do
      api_user2 = foreign_api_user
      assert_equal false, api_user2.read_attribute(:locked)

      post :create, params: { id: api_user2.id }, xhr: true

      api_user2.reload

      assert_equal false, api_user2.read_attribute(:locked)
    end
  end
  
  context '#unlock' do
    test 'user unlocks his api user' do
      @api_user.update_attribute(:locked, true)

      delete :destroy, params: { id: @api_user.id }, xhr: true

      @api_user.reload

      assert_equal false, @api_user.read_attribute(:locked)
    end

    test 'user cannot unlock a foreign api user' do
      api_user2 = foreign_api_user
      api_user2.update_attribute(:locked, true)
      
      delete :destroy, params: { id: api_user2.id }, xhr: true

      api_user2.reload

      assert_equal true, api_user2.read_attribute(:locked)
    end
  end

  private

  def login_as_bob
    login_as(:bob)
  end
  
  def foreign_api_user
    users(:alice).api_users.create!
  end

  def create_api_user
    @api_user = users(:bob).api_users.create!(description: 'my sweet api user')
  end

end
