# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::User::ApisControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#index' do
    test 'user gets his api users' do
      User::Api.any_instance.expects(:init_username)
                            .returns('bob-36438k')
                            .times(2)
      
      login_as(:bob)

      get :index, xhr: true
    
      result_json = JSON.parse(response.body)['data']['user/apis'][0]

      api_user = users(:api)

      assert_equal api_user.username, result_json['label']
      assert_equal api_user.id, result_json['id']
    end
  end
 
  context '#show' do
    test 'user shows his api user' do
      User::Api.any_instance.expects(:init_username)
                            .returns('bob-36438k')
                            .times(3)

      login_as(:bob)

      api_user = users(:api)

      get :show, params: { id: api_user.id }, xhr: true
    
      result_json = JSON.parse(response.body)['data']['user/api']

      assert_equal api_user.username, result_json['label']
      assert_equal api_user.id, result_json['id']
    end
  end
 
  context '#create' do
    test 'user creates api user' do
      login_as(:bob)
      
      api_params = { username: 'api42', type: 'User::Api', human_user_id: users(:bob).id, password: 'password' }
 
      assert_difference('User::Api.count', 1) do
        post :create, params: { user_api: api_params }
      end
    end
  end
  
  context '#update' do
    test 'user updates his api user' do
      login_as(:bob)
      api_user = users(:api)

      update_params = { locked: true }

      post :update, params: { id: api_user.id, user_api: update_params }, xhr: true

      api_user.reload

      assert_equal true, api_user.locked
    end
  end
  
  context '#destroy' do
    test 'user deletes his api user' do
      login_as(:bob)
      api_user = users(:api)

      assert_difference('User::Api.count', -1) do
        delete :destroy, params: { id: api_user.id }
      end
    end
  end
end
