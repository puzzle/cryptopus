#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::AccountsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#index' do
    test 'returns account with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'acc' }, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']
    end

    test 'returns all accounts if empty query param given' do
      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']
    end

    test 'returns all accounts if no query param given' do
      login_as(:alice)

      get :index, xhr: true

      account1_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, account1_json['accountname']
      assert_equal account.id, account1_json['id']
      assert_nil account1_json['cleartext_username']
      assert_nil account1_json['cleartext_password']

      assert_equal group.name, account1_json['group']
      assert_equal group.id, account1_json['group_id']

      assert_equal team.name, account1_json['team']
      assert_equal team.id, account1_json['team_id']
    end

    test 'returns account for matching description without cleartext username / password' do
      login_as(:alice)
      get :index, params: { 'q': 'des' }, xhr: true

      result_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account1)
      group = account.group
      team = group.team

      assert_equal account.accountname, result_json['accountname']
      assert_equal account.id, result_json['id']
      assert_nil result_json['cleartext_username']
      assert_nil result_json['cleartext_password']

      assert_equal group.name, result_json['group']
      assert_equal group.id, result_json['group_id']

      assert_equal team.name, result_json['team']
      assert_equal team.id, result_json['team_id']
    end

    test 'returns account for matching tag without cleartext username / password' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      result_json = JSON.parse(response.body)['data']['accounts'][0]

      account = accounts(:account2)
      group = account.group
      team = group.team

      assert_equal account.accountname, result_json['accountname']
      assert_equal account.id, result_json['id']
      assert_nil result_json['cleartext_username']
      assert_nil result_json['cleartext_password']

      assert_equal group.name, result_json['group']
      assert_equal group.id, result_json['group_id']

      assert_equal team.name, result_json['team']
      assert_equal team.id, result_json['team_id']
    end
  end

  context '#show' do
    test 'return decrypted account' do
      login_as(:bob)
      account = accounts(:account1)

      get :show, params: { id: account }, xhr: true
      account = JSON.parse(response.body)['data']['account']

      assert_equal 'account1', account['accountname']
      assert_equal 'test', account['cleartext_username']
      assert_equal 'password', account['cleartext_password']
    end
  end

  context '#api_user' do
    test 'authenticates with valid api user and returns account details' do
      api_user.update!(valid_until: DateTime.now + 5.minutes)
    
      teams(:team1).add_user(api_user, plaintext_team_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      account = JSON.parse(response.body)['data']['account']

      assert_equal 'account1', account['accountname']
      assert_equal 'test', account['cleartext_username']
      assert_equal 'password', account['cleartext_password']
    end
    
    test 'does not authenticate with invalid api token and does not show account details' do
      api_user.update!(valid_until: DateTime.now + 5.minutes)
    
      teams(:team1).add_user(api_user, plaintext_team_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = Base64.encode64('abcd')

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      assert_includes errors, 'Authentification failed'
      assert_equal 401, JSON.parse(response.code)
    end
    
    test 'cannot authenticate without headers and does not show account details' do
      api_user.update!(valid_until: DateTime.now + 5.minutes)
    
      teams(:team1).add_user(api_user, plaintext_team_password)

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      assert_redirected_to login_login_path
      assert_nil response.body['data']
    end
    
    test 'authenticates and shows account details even if recryptrequests of human user pending' do
      api_user.update!(valid_until: DateTime.now + 5.minutes)

      bob.recryptrequests.create!
      
      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token
    
      teams(:team1).add_user(api_user, plaintext_team_password)

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true
      account = JSON.parse(response.body)['data']['account']

      assert_equal 200, JSON.parse(response.code)
      assert_equal 'account1', account['accountname']
      assert_equal 'test', account['cleartext_username']
      assert_equal 'password', account['cleartext_password']
    end
    
    test 'does not show account details if valid api user not teammember' do
      api_user.update!(valid_until: DateTime.now + 5.minutes)
    
      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      assert_includes errors, 'Access denied'
      assert_equal 500, JSON.parse(response.code)
    end
    
    test 'human user shows account details and does not use api user authenticator if active session' do
      login_as(:bob)

      request.headers['Authorization-User'] = bob.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      Authentication::UserAuthenticator.expects(:new).never

      account = JSON.parse(response.body)['data']['account']

      assert_equal 'account1', account['accountname']
      assert_equal 'test', account['cleartext_username']
      assert_equal 'password', account['cleartext_password']
    end
    
    test 'human user shows account details if headers valid' do
      request.headers['Authorization-User'] = bob.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      account = JSON.parse(response.body)['data']['account']

      assert_equal 'account1', account['accountname']
      assert_equal 'test', account['cleartext_username']
      assert_equal 'password', account['cleartext_password']
    end
  end

  private

  def bob
    users(:bob)
  end

  def api_user
    @api_user ||= bob.api_users.create
  end

  def private_key
    bob.decrypt_private_key('password')
  end

  def plaintext_team_password
    teams(:team1).decrypt_team_password(bob, private_key)
  end

  def token
    decrypted_token = api_user.send(:decrypt_token, private_key)
    Base64.encode64(decrypted_token)
  end

  def errors
    JSON.parse(response.body)['messages']['errors']
  end
end
