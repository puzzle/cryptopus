# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::User::ApisControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  setup :login_as_bob, :create_api_user

  context '#index' do

    test 'user gets his api users' do

      get :index, xhr: true
    
      result_json = JSON.parse(response.body)['data']['user/apis'][0]

      assert_equal @api_user.username, result_json['username']
      assert_equal @api_user.description, result_json['description']
      assert_equal @api_user.valid_for, result_json['valid_for']
      assert_equal @api_user.id, result_json['id']
    end

  end
 
  context '#show' do
    test 'user shows his api user' do
      get :show, params: { id: @api_user.id }, xhr: true
    
      result_json = JSON.parse(response.body)['data']['user/api']

      assert_equal @api_user.username, result_json['username']
      assert_equal @api_user.description, result_json['description']
      assert_equal @api_user.valid_for, result_json['valid_for']
      assert_equal @api_user.id, result_json['id']
    end
  end
 
  context '#create' do
    test 'user creates api user' do

      api_params = { description: 'another api user', valid_for: '300' }
 
      assert_difference('User::Api.count', 1) do

        post :create, params: { user_api: api_params }

      end
    end
  end
  
  context '#update' do
    test 'user updates his api user' do

      update_params = { description: 'my sweetest api user', valid_for: '60' }

      post :update, params: { id: @api_user.id, user_api: update_params }, xhr: true

      @api_user.reload

      assert_equal 60, @api_user.valid_for
      assert_equal 'my sweetest api user', @api_user.description
    end
  end
  
  context '#destroy' do
    test 'user deletes his api user' do

      assert_difference('User::Api.count', -1) do
        delete :destroy, params: { id: @api_user.id }
      end
    end
  end

  private

  def create_api_user
    @api_user = users(:bob).api_users.create!(description: 'my sweet api user')
  end

  def login_as_bob
    login_as(:bob)
  end

end
